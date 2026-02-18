import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:nexxpharma/services/dto/stock_out_dto.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:http/http.dart' as http;

/// Simple module info class for invoice generation
class ModuleInfo {
  final String? name;
  final String? phone;
  final String? email;
  final String? logoUrl;

  ModuleInfo({
    this.name,
    this.phone,
    this.email,
    this.logoUrl,
  });
}

class InvoiceService {
  static Future<Uint8List> generateInvoice(
    StockOutDTO stockOut,
    InvoicePaperSize paperSize, {
    ModuleInfo? moduleInfo,
    bool isWholesale = false,
  }) async {
    switch (paperSize) {
      case InvoicePaperSize.a4:
        return _generateA4Invoice(stockOut, moduleInfo, isWholesale: isWholesale);
      case InvoicePaperSize.mm80:
        return _generateReceiptInvoice(
          stockOut,
          PdfPageFormat.roll80,
          moduleInfo,
          isWholesale: isWholesale,
        );
      case InvoicePaperSize.mm57:
        return _generateReceiptInvoice(
          stockOut,
          PdfPageFormat.roll57,
          moduleInfo,
          isWholesale: isWholesale,
        );
    }
  }

  static Future<Uint8List> _generateA4Invoice(
    StockOutDTO stockOut,
    ModuleInfo? moduleInfo, {
    bool isWholesale = false,
  }) async {
    final pdf = pw.Document();
    final customerLabel = isWholesale ? 'Pharmacy' : 'Patient';
    final payerLabel = isWholesale ? 'Customer Pays:' : 'Patient Pays:';

    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(
      symbol: 'RF ',
      decimalDigits: 0,
    );

    // Load logo if available
    pw.ImageProvider? logoImage;
    if (moduleInfo?.logoUrl != null &&
        (moduleInfo?.logoUrl?.isNotEmpty ?? false)) {
      try {
        final response = await http.get(Uri.parse(moduleInfo!.logoUrl!));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // Logo failed to load, continue without it
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and business info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Business info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (moduleInfo?.name != null)
                          pw.Text(
                            moduleInfo!.name!,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        if (moduleInfo?.phone != null ||
                            moduleInfo?.email != null) ...[
                          pw.SizedBox(height: 4),
                          if (moduleInfo!.phone != null)
                            pw.Text(
                              'Phone: ${moduleInfo.phone}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          if (moduleInfo.email != null)
                            pw.Text(
                              'Email: ${moduleInfo.email}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                        ],
                      ],
                    ),
                  ),
                  // Right side: Logo and Invoice number
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 80,
                          height: 80,
                          child: pw.Image(logoImage),
                        ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Invoice #: INV-${stockOut.id}'),
                      pw.Text(
                          'Date: ${dateFormat.format(stockOut.createdAt)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Patient Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bill To:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('$customerLabel: ${stockOut.patientName}'),
                    if (stockOut.insuranceCardNumber != null) ...[
                      pw.Text('Insurance Card: ${stockOut.insuranceCardNumber}'),
                      if (stockOut.issuingCompany != null)
                        pw.Text('Issuer: ${stockOut.issuingCompany}'),
                    ],
                    if (stockOut.prescriberName != null)
                      pw.Text('Prescriber: ${stockOut.prescriberName}'),
                    pw.Text('Sold By: ${stockOut.userName}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Unit Price', 'Ins. Pay', 'Total'],
                data: stockOut.stockOutItems.map((item) {
                  return [
                    item.productName,
                    item.quantitySold.toString(),
                    currencyFormat.format(item.pricePerUnit),
                    currencyFormat.format(item.insurancePays),
                    currencyFormat.format(item.itemTotal),
                  ] as List<dynamic>;
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text(currencyFormat.format(stockOut.totalPrice)),
                          ],
                        ),
                        pw.Divider(),
                        if (stockOut.stockOutItems
                            .any((i) => i.insurancePays > 0)) ...[
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Insurance Pays:',
                                style: const pw.TextStyle(
                                  color: PdfColors.green700,
                                ),
                              ),
                              pw.Text(
                                '-${currencyFormat.format(stockOut.stockOutItems.fold(0.0, (sum, item) => sum + item.insurancePays))}',
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                        ],
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              payerLabel,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(
                                stockOut.stockOutItems.fold(
                                  0.0,
                                  (sum, item) => sum + item.patientPays,
                                ),
                              ),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> _generateReceiptInvoice(
    StockOutDTO stockOut,
    PdfPageFormat pageFormat,
    ModuleInfo? moduleInfo, {
    bool isWholesale = false,
  }
  ) async {
    final pdf = pw.Document();
    final customerLabel = isWholesale ? 'Pharmacy' : 'Patient';

    final dateFormat = DateFormat('dd/MM/yy HH:mm');
    final currencyFormat = NumberFormat.currency(
      symbol: 'RF ',
      decimalDigits: 0,
    );

    // Load logo if available for receipt
    pw.ImageProvider? logoImage;
    if (moduleInfo?.logoUrl != null &&
        (moduleInfo?.logoUrl?.isNotEmpty ?? false)) {
      try {
        final response = await http.get(Uri.parse(moduleInfo!.logoUrl!));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // Logo failed to load, continue without it
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo and Business Name
              if (logoImage != null)
                pw.Center(
                  child: pw.Container(
                    width: 40,
                    height: 40,
                    child: pw.Image(logoImage),
                  ),
                ),
              if (logoImage != null) pw.SizedBox(height: 4),
              if (moduleInfo?.name != null)
                pw.Center(
                  child: pw.Text(
                    moduleInfo!.name!,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              if (moduleInfo?.name != null) pw.SizedBox(height: 2),
              if (moduleInfo?.phone != null || moduleInfo?.email != null) ...[
                if (moduleInfo!.phone != null)
                  pw.Center(
                    child: pw.Text(
                      moduleInfo.phone!,
                      style: const pw.TextStyle(fontSize: 7),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                if (moduleInfo.email != null)
                  pw.Center(
                    child: pw.Text(
                      moduleInfo.email!,
                      style: const pw.TextStyle(fontSize: 7),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
              ],

              // Header
              pw.Center(
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(),
              pw.SizedBox(height: 4),

              // Invoice Info
              pw.Text(
                'INV-${stockOut.id.substring(0, 8)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                dateFormat.format(stockOut.createdAt),
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 8),

              // Patient Info
              pw.Text(
                '$customerLabel: ${stockOut.patientName}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (stockOut.insuranceCardNumber != null)
                pw.Text(
                  'Card: ${stockOut.insuranceCardNumber}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              if (stockOut.issuingCompany != null)
                pw.Text(
                  stockOut.issuingCompany!,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              pw.Text(
                'By: ${stockOut.userName}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),

              // Items
              ...stockOut.stockOutItems.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 4),
                    pw.Text(
                      item.productName,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${item.quantitySold} x ${currencyFormat.format(item.pricePerUnit)}',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        pw.Text(
                          currencyFormat.format(item.itemTotal),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                    if (item.insurancePays > 0)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Insurance',
                            style: const pw.TextStyle(
                              fontSize: 7,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            '-${currencyFormat.format(item.insurancePays)}',
                            style: const pw.TextStyle(
                              fontSize: 7,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    pw.SizedBox(height: 4),
                  ],
                );
              }).toList(),

              pw.Divider(),
              pw.SizedBox(height: 4),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    currencyFormat.format(stockOut.totalPrice),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              if (stockOut.stockOutItems.any((i) => i.insurancePays > 0)) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Insurance:',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.green700,
                      ),
                    ),
                    pw.Text(
                      '-${currencyFormat.format(stockOut.stockOutItems.fold(0.0, (sum, item) => sum + item.insurancePays))}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    currencyFormat.format(
                      stockOut.stockOutItems.fold(
                        0.0,
                        (sum, item) => sum + item.patientPays,
                      ),
                    ),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Thank you!',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

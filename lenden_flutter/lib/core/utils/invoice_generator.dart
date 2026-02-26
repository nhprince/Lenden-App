import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class InvoiceGenerator {
  static Future<void> generateAndPrintSalesInvoice(Transaction transaction, List<CartItem> items, Shop shop) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(shop.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(shop.address ?? ''),
                      pw.Text(shop.phone ?? ''),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
                      pw.Text('No: #${transaction.id}'),
                      pw.Text('Date: ${transaction.date.toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Billing Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(transaction.customerName ?? 'Walk-in Customer'),
                      pw.Text(transaction.customerPhone ?? ''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Item', 'Qty', 'Unit Price', 'Subtotal'],
                data: items.map((i) => [
                  i.product.name,
                  i.quantity.toString(),
                  'BTDT ${i.price.toStringAsFixed(2)}',
                  'BTDT ${(i.price * i.quantity).toStringAsFixed(2)}',
                ]).toList(),
              ),
              pw.SizedBox(height: 30),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _totalRow('Subtotal:', 'BTDT ${transaction.amount.toStringAsFixed(2)}'),
                      _totalRow('Discount:', 'BTDT ${transaction.discount?.toStringAsFixed(2) ?? "0.00"}'),
                      pw.Divider(),
                      _totalRow('Total:', 'BTDT ${transaction.amount.toStringAsFixed(2)}', isBold: true),
                      _totalRow('Paid:', 'BTDT ${transaction.paidAmount.toStringAsFixed(2)}'),
                      _totalRow('Due:', 'BTDT ${transaction.dueAmount.toStringAsFixed(2)}', color: PdfColors.red700),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              pw.Center(child: pw.Text('Thank you for your business!')),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text('Lenden App - Unified Business Management', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Row _totalRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.SizedBox(width: 20),
        pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
      ],
    );
  }
}

class HtmlTable {
  final List<HtmlRow> headerRows;
  final List<HtmlRow> rows;

  HtmlTable({this.headerRows = const [], this.rows = const []});

  String toHtml() {
    String html = '<table>\n';
    for (var headerRow in headerRows) {
      for (var htmlLine in headerRow.toHtmlLines(isHeader: true)) {
        html += '  $htmlLine';
      }
    }
    for (var row in rows) {
      for (var htmlLine in row.toHtmlLines()) {
        html += '  $htmlLine';
      }
    }

    html += '</table>\n';
    return html;
  }

  @override
  String toString() => toHtml();
}

class HtmlRow {
  final List<int?> colSpans;
  final List<String> values;

  HtmlRow({this.colSpans = const [], required this.values});

  List<String> toHtmlLines({bool isHeader = false}) {
    List<String> htmlLines = [];
    htmlLines.add('<tr>\n');
    for (int i = 0; i < values.length; i++) {
      var collSpan = i < colSpans.length ? colSpans[i] : null;
      htmlLines.add(_createCellHtml(isHeader, values[i], collSpan));
    }
    htmlLines.add('</tr>\n');
    return htmlLines;
  }

  String _createCellHtml(bool isHeader, String value, int? colSpan) {
    String cellHtml = '';
    String collSpanAttribute = colSpan == null ? '' : ' colspan="$colSpan" ';
    cellHtml +=
        isHeader ? '  <th$collSpanAttribute>' : '  <td$collSpanAttribute>';
    cellHtml += value;
    cellHtml += isHeader ? '</th>\n' : '</td>\n';
    return cellHtml;
  }
}

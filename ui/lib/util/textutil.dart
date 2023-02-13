String plainText(String str) {
  RegExp reg = RegExp(r'(<p.*?">|<p>)(.*?)(</p>)');
  Iterable<RegExpMatch> it = reg.allMatches(str);
  String plainText = "";
  if (str.indexOf("</p>") <= 0) {
    return str;
  }
  RegExp replaceReg = RegExp(
      r'(<span.*?>|</span>|<b>|</b>|<br>|<br/>|<br />|<a.*?>|</a>|<img.*?>|<strong.*?>|</strong>|<em>|</em>|&nbsp;)');
  for (var m in it) {
    String v = m.group(2) ?? "";
    String x = v.replaceAll(replaceReg, "");
    plainText = plainText + x;
  }
  return plainText;
}

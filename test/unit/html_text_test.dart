import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/utils/html_text.dart';

void main() {
  group('telling markup from typing', () {
    test('recognises what GLPI\'s editor produces', () {
      expect(
        looksLikeHtml('<p>1. Quit the client<br>2. Delete it</p>'),
        isTrue,
      );
      expect(looksLikeHtml('<ul><li>one</li></ul>'), isTrue);
      expect(looksLikeHtml('a <b>bold</b> claim'), isTrue);
    });

    test('leaves plain text alone', () {
      // Feeding this to an HTML renderer would silently eat the line breaks.
      expect(
        looksLikeHtml('Swapped the switch port.\nStill flapping.'),
        isFalse,
      );
      expect(looksLikeHtml('3 < 5 and 7 > 2'), isFalse);
      expect(looksLikeHtml(''), isFalse);
    });
  });

  group('flattening for one-line places', () {
    test('keeps a procedure readable', () {
      expect(
        htmlToPlainText(
          '<p>Steps:</p><ol><li>Stop it</li><li>Start it</li></ol>',
        ),
        'Steps:\n\n• Stop it\n• Start it',
      );
    });

    test('turns block boundaries into breaks, not run-on text', () {
      expect(htmlToPlainText('<p>one</p><p>two</p>'), 'one\n\ntwo');
      expect(htmlToPlainText('a<br>b'), 'a\nb');
    });

    test('decodes entities', () {
      expect(
        htmlToPlainText('<p>Tom &amp; Jerry &lt;3&gt;&nbsp;ok</p>'),
        'Tom & Jerry <3> ok',
      );
    });

    test('strips the outbox idempotency marker', () {
      // It is a real HTML comment GLPI preserves — useful for dedup, but it
      // must never be shown.
      const raw = '<p>Done</p><!-- op:8a19-6db0-ec55 -->';
      expect(htmlToPlainText(raw), 'Done');
      expect(sanitizeGlpiHtml(raw), '<p>Done</p>');
    });

    test('passes plain text through with its breaks intact', () {
      expect(htmlToPlainText('line one\nline two'), 'line one\nline two');
    });
  });

  group('wrapping typed text for GLPI', () {
    test('one paragraph per blank line, breaks inside', () {
      expect(
        plainTextToHtml('first\nsecond\n\nthird'),
        '<p>first<br>second</p><p>third</p>',
      );
    });

    test('escapes markup a user typed literally', () {
      expect(
        plainTextToHtml('use <b> & </b> tags'),
        '<p>use &lt;b&gt; &amp; &lt;/b&gt; tags</p>',
      );
    });

    test('empty in, empty out', () {
      expect(plainTextToHtml(''), '');
      expect(plainTextToHtml('   \n  '), '');
    });

    test('round-trips back to the same text', () {
      const typed = 'Swapped the port.\nStill flapping.\n\nEscalating.';
      expect(htmlToPlainText(plainTextToHtml(typed)), typed);
    });
  });

  group('markup the mobile editor would destroy', () {
    test('flags tables and images', () {
      // Quill has no table model: importing one returns a paragraph of
      // run-together cells, so editing must be refused rather than silently
      // flattening the author's work.
      expect(
        htmlHasUnsupportedMarkup(
          '<table border="1"><tbody><tr><td>a</td></tr></tbody></table>',
        ),
        isTrue,
      );
      expect(htmlHasUnsupportedMarkup('<p>see <img src="x.png"></p>'), isTrue);
    });

    test('leaves ordinary formatting editable', () {
      expect(
        htmlHasUnsupportedMarkup('<ol><li><strong>bold</strong></li></ol>'),
        isFalse,
      );
      expect(htmlHasUnsupportedMarkup('plain words'), isFalse);
      expect(htmlHasUnsupportedMarkup(''), isFalse);
    });
  });

  test('table cells stay separate values when flattened', () {
    expect(
      htmlToPlainText('<table><tr><td>This</td><td>Is</td></tr></table>'),
      'This | Is',
    );
  });
}

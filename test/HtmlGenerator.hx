import boxup.Block;
import boxup.block.InlineText;
import boxup.block.Text;
import boxup.Generator;
import boxup.block.Paragraph;

class HtmlGenerator implements Generator<String> {
  var pageCount = 0;
  var panelCount = 0;

  public function new() {}

  @generate
  function genComic(comic:Comic) {
    return '<header class="comic">
      <h1>${comic.title}</h1>
      <span class="author">${comic.author}</span>
    </header>';
  }

  @generate
  function genPage(page:Page) {
    pageCount++;
    panelCount = 0;
    return '<div class="page">
      <h2>Page ${pageCount}</h2>
      ${generate(page.content).join('\n')}
    </div>';
  }

  @generate
  function genPanel(panel:Panel) {
    panelCount++;
    return '<div class="panel">
      <h3>Panel ${panelCount}</h3>
      ${generate(panel.children).join('\n')}
    </div>';
  }

  @generate
  function genDialog(dialog:Dialog) {
    return '<div class="dialog">
      <h4 class="dialog-character">${dialog.character}</h4>
      ${generate(dialog.children).join('\n')}
    </div>';
  }

  @generate
  function genNotes(notes:Notes) {
    return '<div class="notes">
      ${generate(notes.content).join('\n')}
    </div>';
  }

  @generate
  function genText(text:Text) {
    return text.content;
  }

  @generate
  function genInlineText(text:InlineText) {
    // we really need to unify what we name our `__text` properties.
    return text.__text;
  }

  @generate
  function genParagraph(para:Paragraph<Link, Emphasis>) {
    return '<p>${generate(para.children).join('')}</p>';
  }

  @generate
  function genDialogParagraph(para:DialogParagraph) {
    return '<p>${generate(para.children).join('')}</p>';
  }

  @generate
  function genLink(link:Link) {
    return '<a href="${link.url}"">${link.label}</a>';
  }

  @generate
  function genEmphasis(emph:Emphasis) {
    return '<b>${emph.value}</b>';
  }

  @generate
  function genAttached(attached:Attached) {
    return '<div class="attached">${generate(attached.children).join('\n')}</div>';
  }

  @generate
  function genMood(mood:Mood) {
    return '<div class="mood"><i>(${mood.description})</i>${generate(mood.children).join('')}</div>';
  }

  public function generateString(blocks:Array<Block>) {
    var output = generate(blocks);
    return '<!doctype html>
      <html>
        <body>
          <style>
            html {
              font-family: "Courier New", Courier;
              font-size: 15px;
              padding: 20px 10px;
            }
            body {
              max-width: 700px;
              margin: 0 auto;
            }
            h1, h2, h3, h4 {
              font-size: inherit;
              font-weight: normal;
              margin: 10px 0;
              text-transform: uppercase;
            }
            .comic {
              margin-bottom: 20px;
            }
            .notes {
              font-style: italic;
              padding: 5px 20px;
              background: #ccc;
            }
            .page {
              border-left: 5px solid #cccccc;
              padding-left: 10px;
              margin-bottom: 20px;
            }
            .page h2 {
              color: #cccccc;
            }
            .panel {

            }
            .dialog {
              text-align: center;
              margin-bottom: 20px;
            }
          </style>

          ${output.join('\n')}
        </body>
      </html>
    ';
  }
}

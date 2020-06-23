#include "base.h"
#include "../fb/text.h"
#include "../defines.h"

namespace ui:
  class Text: public Widget:
    public:
    enum JUSTIFY { LEFT, CENTER, RIGHT }
    string text
    JUSTIFY justify = JUSTIFY::CENTER

    Text(int x, y, w, h, string t): Widget(x, y, w, h):
      self.text = t

    // TODO: cache the image buffer
    void redraw():
      image = freetype::get_text_size(self.text.c_str())

      image.buffer = (uint32_t*) malloc(sizeof(uint32_t) * image.w * image.h)
      memset(image.buffer, WHITE, sizeof(uint32_t) * image.w * image.h)

      leftover_x = self.w - image.w
      padding_x = 0

      switch self.justify:
        case JUSTIFY::LEFT:
          break
        case JUSTIFY::CENTER:
          if leftover_x > 0:
            padding_x = leftover_x / 2
          break
        case JUSTIFY::RIGHT:
          if leftover_x > 0:
            padding_x = leftover_x
          break

      fb->draw_text(self.text, self.x + padding_x, self.y, image)

      free(image.buffer)

  class MultiText: public Text:
    public:
    MultiText(int x, y, w, h, string t): Text(x, y, w, h, t):
      pass

    void redraw():
      cur_x = 0
      cur_y = 0
      tokens = split(self.text, ' ')
      for auto w: tokens:
        w += " "
        image = freetype::get_text_size(w.c_str())
        image.buffer = (uint32_t*) malloc(sizeof(uint32_t) * image.w * image.h)
        memset(image.buffer, WHITE, sizeof(uint32_t) * image.w * image.h)
        if cur_x + image.w >= self.w:
          cur_x = 0
          cur_y += 24
        self.fb->draw_text(w, self.x + cur_x, self.y + cur_y, image)
        free(image.buffer)
        cur_x += image.w

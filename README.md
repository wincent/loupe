![Loupe](https://raw.githubusercontent.com/wincent/loupe/media/loupe-small.jpg)

# Overview

Loupe enhances Vim's `search-commands` in four ways:

## Makes the currently selected match easier to see

When searching using `/`, `?`, `star`, `#`, `n`, `N` or similar, it can be hard to see the "current" match from among all the matches that `'hlsearch'` highlights. Loupe makes the currently selected match easier to see by:

- Applying a different `:highlight` group (by default, `hl-IncSearch`) to the match under the cursor.
- Keeping the matching line centered within the window when jumping between matches with `n` and `N`.

## Applies sane pattern syntax by default

Loupe makes "very magic" (`/\v`) syntax apply by default when searching. This is true even if you initiate a search via a novel means, such as from a visual selection or with a complicated `:range` prefix.

This means that you can use a pattern syntax closer to the familiar regular expression syntax from languages such as Perl, Ruby, JavaScript (indeed, most other modern languages that support regular expressions).

## Provides a shortcut to remove search highlighting

Loupe maps `<Leader>n` to quickly remove all `'hlsearch'` highlighting (although you can provide an alternative mapping of your choosing or suppress the feature entirely).

## Sensible defaults for search-related features

Loupe provides reasonable defaults for most search-related Vim settings to provide a good "out of the box" experience. For more details, or to see how to override Loupe's settings, see `loupe-overrides`.

---

For more information, see [the documentation](https://github.com/wincent/loupe/blob/master/doc/loupe.txt).

wikiMigrate
====================

Migrate from MediaWiki to Wikidot

This is a little script that will help move your files from a MediaWiki site (MW) to a Wikidot site (WD).

What it does:
---------------------
* Downloads your MW files.
* Converts *basic* MW markup to WD syntax.
* Lets you preview the WD versions.
* Uploads the final WD versions to the wikidot site.

Configuration:
---------------------
Comes with a sample_config.rb file.  You'll need to rename it to config.rb and
edit the values with your wikidot and mediawiki info.

Usage:
---------------------
    ruby wikiMigrate.rb <download|convert|preview|upload>
    - Run each phase as many times as you want, but do them in order
     
Disclaimer:
---------------------
This script is provided as-is with no warranty.  It is not a silver bullet for
migration, and has several limitations described in more detail below.

Details:
---------------------
The 'download' phase will grab everything from:
- The root namespace (what you see when you go to the 'All Pages' special page)
- The uploaded files
- The template namespace

It does NOT do anything with Help, Talk, or Nav pages.

The 'convert' phase will convert *basic* wiki syntax to wikidot format:  Bold, italics,
lists, links... that sort of thing.  See markup_converter.rb source for a complete list.
It does NOT do more complicated items like tables, special div/styles, etc.

The 'preview' phase will upload each page one by one to a page named "preview" on your
wikidot site.  This gives you a chance to preview and tweak the wiki markup (on DISK!)
before finally committing.

The 'upload' phase will upload all page and files to the wikidot site.

To get a Wikidot API key, see:  http://developer.wikidot.com/

Credits:
---------------------
Thanks to:
- Jani Patokallio for the Mediawiki Gateway gem (https://github.com/jpatokal/mediawiki-gateway)
- Michal Frackowiak for the Wikidot API gem (https://github.com/michalf/wikidot-api)
- Cameron Sanantonio for the starting point of a MW->WD markup converter (http://autodmc.org/wikimedia-to-wikidot.php)
- The folks at both MW and WD for awesome wiki software.

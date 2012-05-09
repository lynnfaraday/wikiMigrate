class SaferGsub
    def sub(text, pattern, replace)
        wrap_if_no_subs(text, text.gsub!(/#{pattern}/, replace))
    end
    
    def wrap_if_no_subs(original, after_sub)
        after_sub == nil ? original : after_sub
    end
end

class TagMap

    # Match everything printable, in lazy chunks (not greedy whole-line chunks)
    NonGreedyPrintableMatch = "[\x20-\x7E]"
    
    def initialize(mwStart, mwEnd, wdStart, wdEnd)
        @mwStart = mwStart
        @mwEnd = mwEnd
        @wdStart = wdStart
        @wdEnd = wdEnd
        @safeGs = SaferGsub.new
    end
    
    def convert(wikiText)
        pattern = @mwStart + '(' + NonGreedyPrintableMatch + '*?)' + @mwEnd
        replace = @wdStart + '\1' + @wdEnd
            
        @safeGs.sub(wikiText, pattern, replace)
    end
end

class MarkupConverter
        
    def initialize(wikiText)
        @wikiText =  wikiText
        @safeGs = SaferGsub.new
    end
        
    def convert
                
        # Convert  internal links from Wikimedia [[Link Content]] to Wikidot [[[Link Content]]]
        # Note: External links 7.;;
        @wikiText = TagMap.new('\[\[', '\]\]', '[[[', ']]]').convert(@wikiText)

        # Turn categories into comments.  They'll later be converted to tags.
        # Note: Must happen AFTER the link regex, which will add an extra bracket.
        @wikiText = TagMap.new('\[\[\[Category\:', '\]\]\]', '[!--Tag=', '--]').convert(@wikiText)
        
        # Table of Contents
        @safeGs.wrap_if_no_subs(@wikiText, @wikiText.gsub!(/__TOC__/i, '[[toc]]'));
            
        # Comments
        @wikiText = TagMap.new("\<\!--", "--\>", '[!-- ', ' --]').convert(@wikiText)
            
        # Text not to be processed by the WIKI system:
        @wikiText = TagMap.new("<nowiki>", "<\/nowiki>", '@@', '@@').convert(@wikiText)
        @wikiText = TagMap.new("<pre>", "<\/pre>", '@@', '@@').convert(@wikiText)
    
        # Strikeout
        @wikiText = TagMap.new("<s>", "<\/s>", '--', '--').convert(@wikiText)
        @wikiText = TagMap.new("<del>", "<\/del>", '--', '--').convert(@wikiText)
            
        # Underlined
        @wikiText = TagMap.new("<u>", "<\/u>", '__', '__').convert(@wikiText)
        @wikiText = TagMap.new("<ins>", "<\/ins>", '__', '__').convert(@wikiText)

        # Sub/Superscripts
        @wikiText = TagMap.new("<sub>", "<\/sub>", ',,', ',,').convert(@wikiText)
        @wikiText = TagMap.new("<sup>", "<\/sup>", '^^', '^^').convert(@wikiText)
        
        # These two are a bit weird because they need to execute a block to do the substitution,
        # and it doesn't fit the TagMap structure
        

        
        # Convert Headings
        # =Heading1= to + Heading1
        # ==Heading2== to ++ Heading2
        # etc.
        pattern = "(=+)(" + TagMap::NonGreedyPrintableMatch + "*?)=+"
        sub_with_block = @wikiText.gsub!(/#{pattern}/) { |str| ("+" * $1.length) + " " + $2 }
        @safeGs.wrap_if_no_subs(@wikiText, sub_with_block)

        # Include.
        # Note: Must replace spaces.
        pattern = "\\{\\{(" + TagMap::NonGreedyPrintableMatch + "*?)\\}\\}"
        sub_with_block = @wikiText.gsub!(/#{pattern}/) { |str|
            "[[include " + $1 + "]]" }
        @safeGs.wrap_if_no_subs(@wikiText, sub_with_block)
        
        # Convert Lists
        # * Bullet A
        # ** Bullet B
        # ** Bullet C
        # *** Bullet D
        # * Bullet E
        #
        # becomes...
        #
        #* Bullet A
        # * Bullet B
        # * Bullet C
        #  * Bullet D
        #* Bullet E
        #
        # Can also be #'s for a numbered list
        pattern = "(^[\*#]+)(" + TagMap::NonGreedyPrintableMatch + "*?)$"
        sub_with_block = @wikiText.gsub!(/#{pattern}/) { |str|
            listMarker = $1[0,1]
            listLevel = $1.length - 1
            (" " * listLevel) + listMarker + $2  }
        @safeGs.wrap_if_no_subs(@wikiText, sub_with_block)
        
        # Convert Images [[[Image:Picture.jpg]]] to [[image files/Picture.jpg]]
        # Note: assumes that all files will be uploaded to a "files" placeholder page
        # Note #2: Happens after the link regex, which will add an extra bracket.
        pattern = "\\[\\[\\[Image\\:(" + TagMap::NonGreedyPrintableMatch + "*?)\\]\\]\\]"
        sub_with_block = @wikiText.gsub!(/#{pattern}/) { |str|
            "[[image files/" + $1 + "]]" }
        @safeGs.wrap_if_no_subs(@wikiText, sub_with_block)
        
        # Bold and italic
        # NOTE: Do this AFTER the lists so it doesn't get confused for bullets.
        @wikiText = TagMap.new("'{3}", "'{3}", '**', '**').convert(@wikiText)
        @wikiText = TagMap.new("'{2}", "'{2}", '*', '*').convert(@wikiText)
    
        return @wikiText

    end
end
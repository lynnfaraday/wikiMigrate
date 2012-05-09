require "../markup_converter.rb"
require "test/unit"
 
class TestMarkupConverter < Test::Unit::TestCase
 
 # 2 in one line
 # 2 in different lines
 # Embedded with stuff on either side
 # case-sensitive
  
  def test_link
    mw = MarkupConverter.new('Wiki [[link]] test.')
    assert_equal('Wiki [[[link]]] test.', mw.convert)
  end

  def test_link_with_alias
    mw = MarkupConverter.new('This is a [[link|alias]].')
    assert_equal('This is a [[[link|alias]]].', mw.convert)
  end
  
  def test_heading1
    mw = MarkupConverter.new('Wiki\n=Heading Test=')
    assert_equal('Wiki\n+ Heading Test', mw.convert)
  end

  def test_heading2
    mw = MarkupConverter.new('Wiki\n==Heading Test==')
    assert_equal('Wiki\n++ Heading Test', mw.convert)
  end
 
  def test_bold
    mw = MarkupConverter.new('Wiki \'\'\'bold\'\'\' test.')
    assert_equal('Wiki **bold** test.', mw.convert)
  end

  def test_italic
    mw = MarkupConverter.new('Wiki \'\'italic\'\' test.')
    assert_equal('Wiki *italic* test.', mw.convert)
  end

  def test_toc
    mw = MarkupConverter.new('Wiki\n__TOC__\nTest')
    assert_equal('Wiki\n[[toc]]\nTest', mw.convert)
  end
    
  def test_comment
    mw = MarkupConverter.new('Wiki <!--comment--> test.')
    assert_equal('Wiki [!-- comment --] test.', mw.convert)
  end
  
  def test_preformat
    mw = MarkupConverter.new('Wiki <pre>preformatted text</pre> test')
    assert_equal('Wiki @@preformatted text@@ test', mw.convert)
  end
  
  def test_nowiki
    mw = MarkupConverter.new('Wiki <nowiki>no wiki format</nowiki> test')
    assert_equal('Wiki @@no wiki format@@ test', mw.convert)
  end

  def test_strikeout_s
    mw = MarkupConverter.new('Wiki <s>strikeout</s> test')
    assert_equal('Wiki --strikeout-- test', mw.convert)
  end

  def test_strikeout_del
    mw = MarkupConverter.new('Wiki <del>deleted text</del> test')
    assert_equal('Wiki --deleted text-- test', mw.convert)
  end

  def test_underline_u
    mw = MarkupConverter.new('Wiki <u>underlined text</u> test')
    assert_equal('Wiki __underlined text__ test', mw.convert)
  end

  def test_underline_ins
    mw = MarkupConverter.new('Wiki <ins>underlined text</ins> test')
    assert_equal('Wiki __underlined text__ test', mw.convert)
  end

  def test_superscript
    mw = MarkupConverter.new('Wiki <sup>deleted text</sup> test')
    assert_equal('Wiki ^^deleted text^^ test', mw.convert)
  end
  
  def test_subscript
    mw = MarkupConverter.new('Wiki <sub>deleted text</sub> test')
    assert_equal('Wiki ,,deleted text,, test', mw.convert)
  end
  
  def test_list
    mw = MarkupConverter.new("* Bullet A\n** Bullet B\n** Bullet C\n*** Bullet D\n* Bullet E")
    assert_equal("* Bullet A\n * Bullet B\n * Bullet C\n  * Bullet D\n* Bullet E", mw.convert)
  end
  
  def test_category
    mw = MarkupConverter.new('Wiki [[Category:Mycat]] test')
    assert_equal('Wiki [!--Tag=Mycat--] test', mw.convert)
  end
  
  def test_include
    mw = MarkupConverter.new('Wiki {{includedFile}} test.')
    assert_equal('Wiki [[include includedFile]] test.', mw.convert)
  end
  
  def test_image
    mw = MarkupConverter.new('Wiki [[Image:Picture.jpg]] test.')
    assert_equal('Wiki [[image files/Picture.jpg]] test.', mw.convert)
  end
    
end
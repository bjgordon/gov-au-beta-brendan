require 'rails_helper'
include MarkdownHelper

RSpec.describe MarkdownHelper do

  describe '#markdown_content' do
    context 'renders markdown' do
      subject { markdown_content('# Heading') }
      it { is_expected.to have_css('h1') }
    end

    context 'renders consecutive headings' do
      subject { markdown_content("# Heading\n## Heading 2") }
      it { is_expected.to have_css('h2') }
    end

    context 'renders tables' do
      subject { markdown_content("| h1 | h2 |\n|---|---|\n| c1 | c2 |") }
      it { is_expected.to have_css('table') }
      it { is_expected.to have_css('table.content-table') }
    end

    context 'renders links' do
      subject { markdown_content('[a link](http://example.com)') }
      it { is_expected.to have_link('a link', href: 'http://example.com') }
    end

    context 'renders links with a quote' do
      subject { markdown_content('[a "link"](http://example.com)') }
      it { is_expected.to have_link('a "link"', href: 'http://example.com') }
    end

    context 'renders links with an apostrophe' do
      subject { markdown_content("[a link's text](http://example.com)") }
      it { is_expected.to have_link("a link's text", href: 'http://example.com') }
    end

    context 'renders links with a space' do
      subject { markdown_content('[a link](http://example.com/a thing)') }
      it { is_expected.to have_link('a link', href: 'http://example.com/a%20thing') }
    end

    context 'renders links with an img' do
      subject { markdown_content('[![Foo](https://example.com/image.png)](http://example.com)') }
      it { is_expected.to match('<a href="http://example.com"><img src="https://example.com/image.png" alt="Foo"></a>') }
    end

    context 'renders links without script' do
      subject { markdown_content('[<script>alert("Foo")</script>](http://example.com)') }
      it { is_expected.not_to have_css('script') }
    end

    context 'renders links without iframe' do
      subject { markdown_content('[<iframe src="https://bad.com/">foo</iframe>](http://example.com)') }
      it { is_expected.not_to have_css('iframe') }
    end

    context 'changes # links to placeholder span' do
      subject { markdown_content('[a placeholder link](#)') }
      it { is_expected.not_to have_link('a placeholder link', href: '#') }
      it { is_expected.to have_css('span.placeholder-link') }
      it { is_expected.to match('a placeholder link') }
    end

    context 'strips script tags' do
      subject { markdown_content('Stuff<script>alert()</script>') }
      it { is_expected.to match('Stuff') }
      it { is_expected.not_to have_css('script') }
    end

    context 'handles no content' do
      subject { markdown_content(nil) }
      it { is_expected.to be_blank }
    end

    context 'handles tel: telephone links' do
      subject { markdown_content('<a href="tel:133 677">National Relay Service - TTY/voice calls</a>') }
      it { is_expected.to have_link('National Relay Service - TTY/voice calls',
                                    :href => "tel:133%20677") }
    end

    context 'creates toc data' do
      subject { markdown_content("## heading one\n## heading two") }
      it { is_expected.to have_css('#heading-one') }
      it { is_expected.to have_css('#heading-two') }
    end
  end

  describe '#markdown_toc' do
    context 'creates an html list of headings' do
      subject { markdown_toc("## heading one\n## heading two") }
      it { is_expected.to have_css('ul') }
      it { is_expected.to have_link('heading one', href: '#heading-one') }
      it { is_expected.to have_link('heading two', href: '#heading-two') }
    end

    context 'stops at h2 by default' do
      subject { markdown_toc("## heading one\n### heading two") }
      it { is_expected.to have_css('ul') }
      it { is_expected.to have_link('heading one', href: '#heading-one') }
      it { is_expected.not_to have_link('heading two') }
    end

    context 'sets nesting level' do
      subject { markdown_toc("## heading one\n### heading two", 3) }
      it { is_expected.to have_css('ul') }
      it { is_expected.to have_link('heading one', href: '#heading-one') }
      it { is_expected.to have_link('heading two', href: '#heading-two') }
    end
  end
end
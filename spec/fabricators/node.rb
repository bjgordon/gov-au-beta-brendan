# FIXME: rename this node_defaults to prevent instantiation
Fabricator(:node) do
  name { Fabricate.sequence(:node_name) { |i| "node-#{i}" } }
  state 'published'
  short_summary 'A single sentence'
  summary 'A paragraph'
  content_body { Fabricate.sequence(:content_body) { |i| "Random content #{i}" } }

  parent do |attrs|
    if attrs[:parent].present?
      attrs[:parent]
    else
      Fabricate(:section_home)
    end
  end

  section do |attrs|
    if attrs[:parent].present?
      attrs[:parent].section
    end
  end
end

Fabricator(:general_content, from: :node, class_name: :general_content) do
  name { Fabricate.sequence(:general_content_name) { |i| "general_content-#{i}" } }
end

Fabricator(:news_article, from: :node, class_name: :news_article) do
  name { Fabricate.sequence(:news_name) { |i| "news-#{i}" } }
  short_summary 'foo'
  release_date Date.today
  summary 'foobar'
end

Fabricator(:root_node, class_name: :root_node) do
  state 'published'
  content_body 'Welcome to gov.au'
end

Fabricator(:section_home, class_name: :section_home, from: :node) do
  parent do |attrs|
    if Node.root_node.present?
      Node.root_node
    else
      Fabricate(:root_node)
    end
  end
  section do |attrs|
    if attrs[:section].present?
      attrs[:section]
    else
      Fabricate(:department)
    end
  end

  after_build do |section_home, _transients|
    section_home.name = section_home.section.name
  end
end

Fabricator(:custom_template_node, class_name: :custom_template_node, from: :node) do
  name { Fabricate.sequence(:custom_template_node_name) { |i| "custom-template-node-#{i}" } }
  template 'custom/public_holidays_tas'
end

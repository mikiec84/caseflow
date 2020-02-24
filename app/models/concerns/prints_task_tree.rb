# frozen_string_literal: true

module PrintsTaskTree
  extend ActiveSupport::Concern
  include TaskTreeRenderModule

  def self.included(other)
    other.class_eval { alias_method :sr, :structure_render }
  end

  def structure_render(*atts, **kwargs)
    TTY::Tree.new(structure(*atts, **kwargs)).render
  end

  def sra(*atts)
    structure_render(*atts, abbreviate: true)
  end

  def srr(*atts)
    puts structure_render(*atts) # rubocop: disable Rails/Output
  end

  def srra(*atts)
    puts sra(*atts) # rubocop: disable Rails/Output
  end

  def structure(*atts, **kwargs)
    abbreviate = kwargs&.dig(:abbreviate) == true
    class_name = abbreviate ? self.class.name.scan(/\p{Upper}/).join : self.class.name
    leaf_name = "#{class_name} #{task_tree_attributes(*atts)}"
    { "#{leaf_name}": task_tree_children.map { |child| child.structure(*atts, **kwargs) } }
  end

  def structure_as_json(*atts)
    leaf_name = self.class.name
    child_tree = task_tree_children.map { |child| child.structure_as_json(*atts) }
    { "#{leaf_name}": task_tree_attributes_as_json(*atts).merge(tasks: child_tree) }
  end

  private

  def task_tree_children
    return children.order(:id) if is_a? Task

    tasks.where(parent_id: nil).order(:id)
  end

  def task_tree_attributes(*atts)
    return attributes_to_s(*atts) if is_a? Task

    "#{id} [#{atts.join(', ')}]"
  end

  def task_tree_attributes_as_json(*atts)
    return attributes_to_h(*atts) if is_a? Task

    { id: id }
  end

  def attributes_to_h(*atts)
    atts.map { |att| [att, self[att]] }.to_h
  end

  def attributes_to_s(*atts)
    atts.map { |att| self[att].presence || "(#{att})" }.flatten.compact.join(", ")
  end
end

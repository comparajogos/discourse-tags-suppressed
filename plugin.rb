# frozen_string_literal: true

# name: discourse-tags-suppressed
# about: Suppress tags from latest topics page.
# version: 0.1
# authors: Compara Jogos
# url: https://github.com/comparajogos/discourse-tags-suppressed

after_initialize do
  if TopicQuery.respond_to?(:results_filter_callbacks)
    remove_suppressed_tag_topics =
      Proc.new do |list_type, result, user, options|
        tags = (SiteSetting.tags_suppressed_from_latest.presence || "").split("|")

        if tags.blank? || list_type != :latest || options[:category] || options[:tags]
          result
        else
          result.where(
            "NOT EXISTS (
              SELECT 1 FROM topic_tags
              JOIN tags ON topic_tags.tag_id = tags.id
              WHERE topic_tags.topic_id = topics.id AND tags.name IN (?))",
            tags,
          )
        end
      end

    TopicQuery.results_filter_callbacks << remove_suppressed_tag_topics
  end
end

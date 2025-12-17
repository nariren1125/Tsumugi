module PostsHelper
  def random_masking_tape_class
    %w[
      masking-tape--amber
      masking-tape--pink
      masking-tape--mint
      masking-tape--blue
    ].sample
  end

  def random_tape_rotation
    rand(-15..15)
  end
end

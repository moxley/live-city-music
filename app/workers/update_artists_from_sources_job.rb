class UpdateArtistsFromSourcesJob
  def self.perform
    new.perform
  end

  def perform
    artists.each do |a|
      UpdateArtistReverbJob.perform_async(a.id)
    end
  end

  private

  def artists
    Artist.
      joins("LEFT JOIN job_runs on job_runs.target_type = 'Artist' AND job_runs.target_id=artists.id").
      where("job_runs.id IS NULL OR (job_runs.job_type=? AND job_runs.sub_type=? AND job_runs.created_at < ?)", 'artist_source_update', 'reverb',
            1.week.ago).
      order("CASE WHEN job_runs.created_at IS NULL THEN DATE('1900-01-01') ELSE job_runs.created_at END")
  end
end

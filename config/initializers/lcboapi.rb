module LCBOAPI

  def self.recache
    rid = _release_id
    RDB.set('lcboapi:release_id', rid)
    rid
  end

  def self.revfile
    (Rails.root + 'REVISION').to_s
  end

  def self.has_revfile?
    File.exists?(revfile)
  end

  def self.revision
    if has_revfile?
      File.read(revfile).strip[0,8]
    else
      Time.now.to_i.to_s
    end
  end

  def self.last_crawl_id
    Crawl.order(:id.desc).first.id
  end

  def self._release_id
    Digest::SHA1.hexdigest("#{last_crawl_id}#{revision}")[0,8]
  end

  def self.release_id
    recache if Rails.env.development?
    (rid = RDB.get('lcboapi:release_id')) ? rid : recache
  end

end

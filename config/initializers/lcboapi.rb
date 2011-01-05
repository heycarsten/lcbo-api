module LCBOAPI

  def self.recache
    rid = _cache_stamp
    RDB.set('lcboapi:cache_stamp', rid)
    rid
  end

  def self.flush
    recache
    $memcache.flush
  end

  def self.revfile
    (Rails.root + 'REVISION').to_s
  end

  def self.has_revfile?
    File.exists?(revfile)
  end

  def self.revision
    if has_revfile?
      File.read(revfile).strip[0,7]
    else
      Time.now.to_i.to_s
    end
  end

  def self.last_crawl_id
    Crawl.order(:id.desc).first.id
  end

  def self._cache_stamp
    "#{last_crawl_id}#{revision}"
  end

  def self.cache_stamp
    (rid = RDB.get('lcboapi:cache_stamp')) ? rid : recache
  end

end

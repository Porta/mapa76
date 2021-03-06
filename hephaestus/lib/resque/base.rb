class Base
  def self.before_perform(*args)
    logging('start', args)
    begin_task(args.first)
    store_status('start', args.first)
  end

  def self.after_perform(*args)
    logging('end', args)
    store_status('end', args.first)
    update_history(args.first)
    Resque.enqueue(DocumentProcessBootstrapTask, *args)
  end

  def self.on_failure(e, *args)
    id = args[0]
    begin
      document = Document.find(id)
      document.status_msg = "Error"
      document.status = "FAILED"
      document.percentage = -1
      document.save
      store_failure(e, args)
    rescue Mongoid::Errors::DocumentNotFound
      logging("Document not found. #{id}")
    end
    logging('failure', args)
  end

  def self.logging(msg, args = nil)
    if args
      logger.info "[#{msg}] #{@queue} with #{args}"
    else
      logger.info "[#{msg}] #{@queue} without args"
    end
  end

  def self.begin_task(document_id)
    Document.find(document_id).update_attribute :status_msg, "#{@msg}"
  end

  def self.store_status(msg, document_id)
    Document.find(document_id).update_attribute :status, "#{@queue}-#{msg}"
  end

  def self.update_history(document_id)
    document = Document.find(document_id)
    document.status_history << @queue
    document.save
  end

  def self.store_failure(e, args=[])
    id = args[0]
    DocumentFailure.create document_id: id, message: e.message, backtrace: e.backtrace.join("\n")
  end

  def self.update_history(document_id)
    document = Document.find(document_id)
    document.status_history << @queue
    document.save
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MessageByDefaultTest < ActiveSupport::TestCase
  def setup
    @message = Message.new
  end
  
  def test_should_not_have_a_sender
    assert_nil @message.sender
  end
  
  def test_should_not_have_a_subject
    assert @message.subject.blank?
  end
  
  def test_should_not_have_a_body
    assert @message.body.blank?
  end
  
  def test_should_be_in_the_unsent_state
    assert_equal 'unsent', @message.state
  end
  
  def test_should_not_be_hidden
    assert_nil @message.hidden_at
    assert !@message.hidden?
  end
end

class MessageTest < ActiveSupport::TestCase
  def test_should_be_valid_with_a_set_of_valid_attributes
    message = new_message
    assert message.valid?
  end
  
  def test_should_require_a_sender_id
    message = new_message(:sender => nil)
    assert !message.valid?
    assert message.errors.invalid?(:sender_id)
  end
  
  def test_should_require_a_sender_type
    message = new_message(:sender => nil)
    assert !message.valid?
    assert message.errors.invalid?(:sender_type)
  end
  
  def test_should_require_a_state
    message = new_message(:state => nil)
    assert !message.valid?
    assert message.errors.invalid?(:state)
  end
  
  def test_should_not_require_a_subject
    message = new_message(:subject => nil)
    assert message.valid?
  end
  
  def test_should_not_require_a_body
    message = new_message(:body => nil)
    assert message.valid?
  end
  
  def test_should_protect_attributes_from_mass_assignment
    message = Message.new(
      :id => 1,
      :sender_id => 1,
      :sender_type => 'User',
      :subject => 'New features',
      :body => 'Find out more!',
      :to => [1, 2],
      :cc => [3, 4],
      :bcc => [5, 6],
      :state => 'sent',
      :hidden_at => Time.now
    )
    
    assert_nil message.id
    assert_nil message.sender_id
    assert message.sender_type.blank?
    assert_equal 'New features', message.subject
    assert_equal 'Find out more!', message.body
    assert_equal [1, 2], message.to
    assert_equal [3, 4], message.cc
    assert_equal [5, 6], message.bcc
    assert_equal 'unsent', message.state
    assert_nil message.hidden_at
  end
end

class MessageBeforeBeingCreatedTest < ActiveSupport::TestCase
  def setup
    @message = new_message
  end
  
  def test_should_not_have_any_recipients
    assert @message.recipients.empty?
  end
  
  def test_should_not_have_any_to_receivers
    assert @message.to.empty?
  end
  
  def test_should_allow_to_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.to(user)
    assert_equal [user], @message.to
  end
  
  def test_should_not_have_any_cc_receivers
    assert @message.cc.empty?
  end
  
  def test_should_allow_cc_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.cc(user)
    assert_equal [user], @message.cc
  end
  
  def test_should_not_have_any_bcc_receivers
    assert @message.bcc.empty?
  end
  
  def test_should_allow_bcc_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.bcc(user)
    assert_equal [user], @message.bcc
  end
end

class MesageAfterBeingCreatedTest < ActiveSupport::TestCase
  def setup
    @message = create_message
  end
  
  def test_should_record_when_it_was_created
    assert_not_nil @message.created_at
  end
  
  def test_should_record_when_it_was_updated
    assert_not_nil @message.updated_at
  end
  
  def test_should_not_have_any_recipients
    assert @message.recipients.empty?
  end
  
  def test_should_not_have_any_to_receivers
    assert @message.to.empty?
  end
  
  def test_should_allow_to_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.to(user)
    assert_equal [user], @message.to
  end
  
  def test_should_not_have_any_cc_receivers
    assert @message.cc.empty?
  end
  
  def test_should_allow_cc_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.cc(user)
    assert_equal [user], @message.cc
  end
  
  def test_should_not_have_any_bcc_receivers
    assert @message.bcc.empty?
  end
  
  def test_should_allow_bcc_receivers_to_be_built
    user = create_user(:login => 'coward')
    @message.bcc(user)
    assert_equal [user], @message.bcc
  end
end

class MessageWithoutRecipientsTest < ActiveSupport::TestCase
  def setup
    @message = create_message
  end
  
  def test_should_not_be_able_to_queue
    assert !@message.queue
  end
  
  def test_should_not_be_able_to_deliver
    assert !@message.deliver
  end
end

class MessageWithRecipientsTest < ActiveSupport::TestCase
  def setup
    @erich = create_user(:login => 'Erich')
    @richard = create_user(:login => 'Richard')
    @ralph = create_user(:login => 'Ralph')
    @message = create_message(
      :to => @erich,
      :cc => @richard,
      :bcc => @ralph
    )
  end
  
  def test_should_have_recipients
    assert_equal 3, @message.recipients.count
  end
  
  def test_should_have_to_receivers
    assert_equal [@erich], @message.to
  end
  
  def test_should_have_cc_receivers
    assert_equal [@richard], @message.cc
  end
  
  def test_should_have_bcc_receivers
    assert_equal [@ralph], @message.bcc
  end
  
  def test_should_be_able_to_queue
    assert @message.queue
  end
  
  def test_should_be_able_to_deliver
    assert @message.deliver
  end
end

class MessageQueuedTest < ActiveSupport::TestCase
  def setup
    @message = create_message(:to => create_user(:login => 'coward'))
    @message.queue
  end
  
  def test_should_be_in_the_queued_state
    assert_equal 'queued', @message.state
  end
  
  def test_should_not_be_able_to_queue
    assert !@message.queue
  end
  
  def test_should_be_able_to_deliver
    assert @message.deliver
  end
end

class MessageDeliveredTest < ActiveSupport::TestCase
  def setup
    @message = create_message(:to => create_user(:login => 'coward'))
    @message.deliver
  end
  
  def test_should_be_in_the_sent_state
    assert_equal 'sent', @message.state
  end
  
  def test_should_not_be_able_to_queue
    assert !@message.queue
  end
  
  def test_should_not_be_able_to_deliver
    assert !@message.deliver
  end
end

class MessageHiddenTest < ActiveSupport::TestCase
  def setup
    @message = create_message
    @message.hide
  end
  
  def test_should_record_when_it_was_hidden
    assert_not_nil @message.hidden_at
  end
  
  def test_should_be_hidden
    assert @message.hidden?
  end
  
  def test_should_not_be_visible
    assert !@message.visible?
  end
end

class MessageUnhiddenTest < ActiveSupport::TestCase
  def setup
    @message = create_message
    @message.hide
    @message.unhide
  end
  
  def test_should_not_have_the_recorded_value_when_it_was_hidden
    assert_nil @message.hidden_at
  end
  
  def test_should_not_be_hidden
    assert !@message.hidden?
  end
  
  def test_should_be_visible
    assert @message.visible?
  end
end

class MessageForwardedTest < ActiveSupport::TestCase
  def setup
    @admin = create_user(:login => 'admin')
    original_message = create_message(
      :subject => 'Hello',
      :body => 'How are you?',
      :sender => @admin,
      :to => create_user(:login => 'Erich'),
      :cc => create_user(:login => 'Richard'),
      :bcc => create_user(:login => 'Ralph')
    )
    @message = original_message.forward
  end
  
  def test_should_be_in_unsent_state
    assert_equal 'unsent', @message.state
  end
  
  def test_should_not_be_hidden
    assert !@message.hidden?
  end
  
  def test_should_have_original_subject
    assert_equal 'Hello', @message.subject
  end
  
  def test_should_have_original_body
    assert_equal 'How are you?', @message.body
  end
  
  def test_should_use_same_sender
    assert_equal @admin, @message.sender
  end
  
  def test_should_not_include_to_recipients
    assert @message.to.empty?
  end
  
  def test_should_not_include_cc_recipients
    assert @message.cc.empty?
  end
  
  def test_should_not_include_bcc_recipients
    assert @message.bcc.empty?
  end
end

class MessageRepliedTest < ActiveSupport::TestCase
  def setup
    @admin = create_user(:login => 'admin')
    @erich = create_user(:login => 'Erich')
    @richard = create_user(:login => 'Richard')
    @ralph = create_user(:login => 'Ralph')
    
    @original_message = create_message(
      :subject => 'Hello',
      :body => 'How are you?',
      :sender => @admin,
      :to => @erich,
      :cc => @richard,
      :bcc => @ralph
    )
    @message = @original_message.reply
  end
  
  def test_should_store_the_original_message
    assert_equal @original_message, @message.original_message
  end
  
  def test_should_be_in_unsent_state
    assert_equal 'unsent', @message.state
  end
  
  def test_should_not_be_hidden
    assert !@message.hidden?
  end
  
  def test_should_have_original_subject
    assert_equal 'Hello', @message.subject
  end
  
  def test_should_have_original_body
    assert_equal 'How are you?', @message.body
  end
  
  def test_should_have_thread
    second_reply = @message.reply
    assert_equal [@message, @original_message], second_reply.thread
  end
  
  def test_should_use_same_sender
    assert_equal @admin, @message.sender
  end
  
  def test_should_use_same_to_recipients
    assert_equal [@erich], @message.to
  end
  
  def test_should_not_include_cc_recipients
    assert @message.cc.empty?
  end
  
  def test_should_not_include_bcc_recipients
    assert @message.bcc.empty?
  end
end

class MessageRepliedToAllTest < ActiveSupport::TestCase
  def setup
    @admin = create_user(:login => 'admin')
    @erich = create_user(:login => 'Erich')
    @richard = create_user(:login => 'Richard')
    @ralph = create_user(:login => 'Ralph')
    
    original_message = create_message(
      :subject => 'Hello',
      :body => 'How are you?',
      :sender => @admin,
      :to => @erich,
      :cc => @richard,
      :bcc => @ralph
    )
    @message = original_message.reply_to_all
  end
  
  def test_should_be_in_unsent_state
    assert_equal 'unsent', @message.state
  end
  
  def test_should_not_be_hidden
    assert !@message.hidden?
  end
  
  def test_should_have_original_subject
    assert_equal 'Hello', @message.subject
  end
  
  def test_should_have_original_body
    assert_equal 'How are you?', @message.body
  end
  
  def test_should_use_same_sender
    assert_equal @admin, @message.sender
  end
  
  def test_should_use_same_to_recipients
    assert_equal [@erich], @message.to
  end
  
  def test_should_use_same_cc_recipients
    assert_equal [@richard], @message.cc
  end
  
  def test_should_use_same_bcc_recipients
    assert_equal [@ralph], @message.bcc
  end
end

class MessageAsAClassTest < ActiveSupport::TestCase
  def setup
    @hidden_message = create_message(:hidden_at => Time.now)
    @visible_message = create_message
  end
  
  def test_should_include_only_visible_messages_in_visible_scope
    assert_equal [@visible_message], Message.visible
  end
end

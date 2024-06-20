desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  puts "Sample data task running"
  if Rails.env.development?
    # added destory all users when rake sample_data is ran
    User.destroy_all
    Board.destroy_all
    Post.destroy_all
  end

  if Rails.env.production?
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end

  # created new user 
  usernames = ["alice", "bob", "carol", "dave", "eve"]

  usernames.each do |username|
    user = User.new
    user.email = "#{username}@example.com"
    user.password = "password"
    user.save
  end
  
  5.times do
    board = Board.new
    board.name = Faker::Address.community
    # make sure the boards are assigned to random users from the usernames 
    board.user_id = User.all.sample.id
    board.save

    rand(10..50).times do
      post = Post.new
      post.board_id = board.id
      # make sure the posts are also assigned to random users from the usernames 
      post.user_id = User.all.sample.id
      post.title = rand < 0.5 ? Faker::Commerce.product_name : Faker::Job.title
      post.body = Faker::Lorem.paragraphs(number: rand(1..5), supplemental: true).join("\n\n")
      post.created_at = Faker::Date.backward(days: 120)
      post.expires_on = post.created_at + rand(3..90).days
      post.save
    end
  end

  puts "There are now #{Board.count} rows in the boards table."
  puts "There are now #{User.count} rows in the users table."
  puts "There are now #{Post.count} rows in the posts table."
end

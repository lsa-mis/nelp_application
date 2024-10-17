# lib/tasks/check_sequences.rake

namespace :db do
  desc "Check and verify PostgreSQL sequences for integer primary keys"

  task check_sequences: :environment do
    ActiveRecord::Base.connection.tables.each do |table|
      primary_key = ActiveRecord::Base.connection.primary_key(table)
      next unless primary_key

      # Retrieve column information for the primary key
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == primary_key }

      # Skip if the primary key is not an integer or bigint
      next unless column && [:integer, :bigint].include?(column.type)

      # Construct the expected sequence name
      sequence = "#{table}_#{primary_key}_seq"

      # Check if the sequence exists
      sequence_exists = ActiveRecord::Base.connection.select_value(<<-SQL)
        SELECT EXISTS (
          SELECT 1
          FROM pg_class c
          JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind = 'S' AND c.relname = '#{sequence}'
        )
      SQL

      unless sequence_exists
        puts "⚠️  Table: #{table} has an integer primary key '#{primary_key}', but sequence '#{sequence}' does not exist."
        next
      end

      # Retrieve the maximum id and current sequence value
      max_id = ActiveRecord::Base.connection.select_value("SELECT MAX(#{primary_key}) FROM #{table}").to_i
      current_seq = ActiveRecord::Base.connection.select_value("SELECT last_value FROM #{sequence}").to_i

      if current_seq < max_id
        puts "🔴 Table: #{table}, MAX ID: #{max_id}, Sequence Value: #{current_seq} -- Needs Reset"
      else
        puts "✅ Table: #{table}, Sequence is up-to-date."
      end
    end
  end
end
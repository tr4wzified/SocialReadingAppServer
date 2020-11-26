# frozen_string_literal: true

require 'httparty'

# Book object containing information about books
class Book
  def value_of(array, value)
    array.nil? || array[value].nil? ? '' : array[value]
  end

  def initialize(openlibrary_id)
    # Raw data
    uri = URI("https://openlibrary.org/works/#{openlibrary_id}.json")
    work_data = JSON.parse(HTTParty.get(uri).to_s)

    uri = URI("https://openlibrary.org/books/#{openlibrary_id}.json")
    book_data = JSON.parse(HTTParty.get(uri).to_s)

    @id = openlibrary_id
    @title = value_of(work_data, 'title')
    @description = value_of(work_data['description'], 'value')
    @subjects = value_of(book_data, 'subjects')
    @publish_date = value_of(work_data, 'publish_date')
    @amazon_id = value_of(value_of(work_data, 'identifiers'), 'amazon').to_s.delete '["]'
    @amazon_link = @amazon_id == '' ? '' : "https://www.amazon.com/dp/#{amazon_id}"

    # Getting author depends on the way it's stored in openlibrary
    if work_data['authors']
      begin
        uri = URI("https://openlibrary.org#{work_data['authors'][0]['key']}.json")
        author_data = JSON.parse(HTTParty.get(uri).to_s)
      rescue
        uri = URI("https://openlibrary.org#{work_data['authors'][0]['author']['key']}.json")
        author_data = JSON.parse(HTTParty.get(uri).to_s)
      end
      @author = value_of(author_data, 'name')
      # remove /authors/ from /authors/<author_id>
      @author_id = author_data['key'].delete('/authors/')
    else
      @author = value_of(work_data, 'by_statement')
    end
  end

  attr_reader :id, :title, :author_id, :author, :description, :subjects, :publish_date, :amazon_id, :amazon_link

  def print_details
    puts "Id: #{@id}"
    puts "Title: #{@title}"
    puts "Description: #{@description}"
    puts "Author: #{@author}"
    puts "Author ID: #{@author_id}"
    puts "Subjects: #{@subjects}"
    puts "Publish Date: #{@publish_date}"
    puts "Amazon ID: #{@amazon_id}"
    puts "Amazon Link: #{@amazon_link}"
  end

  def to_hash
    Hash[instance_variables.map { |var| [var.to_s[1..-1], instance_variable_get(var)] }]
  end

end

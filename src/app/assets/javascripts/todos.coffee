# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Some helpers #
################
generateTagHtml = (name, deletable) ->
  name = $('<div/>').text(name).html()
  if ['urgent', 'important', 'asap', 'high priority'].indexOf(name.toLowerCase()) != -1
    type = 'label-danger'
  else
    type = 'label-info'
  if deletable
    return '<h4><span class="label ' + type + '"><span class="glyphicon glyphicon-remove" id="tag-remove-button" aria-hidden="true"></span> ' + name + '</span></h4>'
  else
    return '<a class="tag-filter" data-remote="true" href="/todos/' + name + '"><span class="label ' + type + '">' + name + '</span><br></a>'

updateTags = ->
  $.ajax({
    url: '/todos/tags',
    type: 'GET',
    crossDomain: false,
    dataType: 'json',
    success: (data) ->
      $('.all-tags').empty()
      for tag in data
        $('.all-tags').append(generateTagHtml(tag.name, false))
      list = $('.all-tags').find('.tag-filter').sort(sortTags)
      $('.all-tags').append(list)

    error: (xhr, status) ->
      console.log(status)
  })

sortTags = (a, b) ->
  if $(a).find('.label').attr('class') > $(b).find('.label').attr('class')
    return 1
  else
    return -1


# When page is loaded #
#######################
$(document).ready ->

  # Activate Best In Place
  $(".best_in_place").best_in_place()

  # Initialize tooltip
  $('[data-toggle="tooltip"]').tooltip()

  # Initialize popover
  $('[data-toggle="popover"]').popover({
    html: true;
    container: 'body',
    placement: 'bottom',
    content: ->
      return $('#add-tags-popover').html()
  })

  # Show tags when the page is loaded
  updateTags()

  # Stores the number of active the completed todos
  pendingCount = parseInt($('.todo-pending-count').html())
  doneCount = parseInt($('.todo-done-count').html())

  # Autofocus add tag field
  $('#add-tags-button')
    .on 'shown.bs.popover', ->
      $('.popover-content #add_tag_field').focus()
      # Delete button for pending tags
      $('.popover-content #pending-tags').on 'click', '#tag-remove-button', (e, data, status, xhr) ->
        tag = $(e.target).closest('h4')
        tagName = tag.text().trim()
        $('#todo_tag_list').val($('#todo_tag_list').val().replace(tagName + ', ', ''))
        $('.hidden #pending-tags').find('h4:contains(' + tagName + ')').remove()
        tag.remove()
    .on 'hidden.bs.popover', ->
      $('#todo_title').focus()


  # Selected filter will have bigger size
  $('.tags .default-tag-filter').css({'font-size':'2em', 'padding-left':'0px'})
  # Scale the filter button after choosing that filter
  $('.tags').on 'ajax:success', '.tag-filter', (e, data, status, xhr) ->
    $('.todo-list').empty().append(data)
    $('.tag-filter').not(e.target).animate({'font-size':'1.2em', 'padding-left':'16px'}, 'fast')
    $(e.target).animate({'font-size':'2em', 'padding-left':'0px'}, 'fast')


  # New todo added
  $('#new_todo').on 'ajax:success', (e, data, status, xhr) ->
    if status != 'nocontent'
      $('.todo-active tbody').prepend(data)
      $('.todo-pending-count').html(++pendingCount)
      $('#todo_tag_list').val ''
      $('#todo_title').val ''
      $('.hidden #pending-tags').empty()
      $('[data-toggle="popover"]').popover('hide')
      $('.default-tag-filter').click()
      updateTags()


  # Todos
  $('.todo-list')
    # Deleting a todo
    .on 'ajax:success', '.todo-active .todo-delete', (e, data, status, xhr) ->
      $(e.target).closest('tr').remove()
      $('.todo-pending-count').html(--pendingCount)
      updateTags()
    .on 'ajax:success', '.todo-done .todo-delete', (e, data, status, xhr) ->
      $(e.target).closest('tr').remove()
      $('.todo-done-count').html(--doneCount)
      updateTags()
    # Toggling a todo
    .on 'ajax:success', '.todo-active [data-bip-attribute="completed"]', (e, data, status, xhr) ->
      $(e.target).closest('tr').appendTo('.todo-done tbody').slideDown()
      $('.todo-pending-count').html(--pendingCount)
      $('.todo-done-count').html(++doneCount)
    .on 'ajax:success', '.todo-done [data-bip-attribute="completed"]', (e, data, status, xhr) ->
      $(e.target).closest('tr').appendTo('.todo-active tbody')
      $('.todo-done-count').html(--doneCount)
      $('.todo-pending-count').html(++pendingCount)
    # Hovering on a todo to show tags
    .on 'mouseenter', '.todo-title', (e, data, status, xhr) ->
      tags = $(e.target).data('tags')
      if tags
        tags = String(tags).split(', ')
        for tag in tags
          $('.tag-filter').filter(->
              return $(this).text() == tag
            ).find('.label').addClass('label-warning')
    .on 'mouseleave', '.todo-title', (e, data, status, xhr) ->
      $('.tag-filter .label').removeClass('label-warning')


  # When press enter on add_tag_field, update the hidden input field and render the tags
  $(document).on 'keydown', '#add_tag_field', (e) ->
    if e.which == 13 && $(this).val()
      $('#todo_tag_list').val($('#todo_tag_list').val() + $(this).val() + ', ')
      tag_content = generateTagHtml($(this).val(), true)
      $('.popover #pending-tags').prepend(tag_content)
      $('.hidden #pending-tags').prepend(tag_content)
      $(this).val ''



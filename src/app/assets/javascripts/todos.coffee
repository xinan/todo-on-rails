# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  currentFilter = null

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

  # Autofocus add tag field
  $('#add-tags-button').on 'shown.bs.popover', ->
    $('.popover-content #add_tag_field').focus()
    # Delete a pending tag
    $('.popover-content #pending-tags').on 'click', '#tag-remove-button', (e, data, status, xhr) ->
      tag = $(e.target).closest('h4')
      tagName = tag.text().trim()
      $('#todo_tag_list').val($('#todo_tag_list').val().replace(tagName + ', ', ''))
      $('.hidden #pending-tags').find('h4:contains(' + tagName + ')').remove()
      tag.remove()

  $('#add-tags-button').on 'hidden.bs.popover', ->
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
      $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) + 1)
      $('#todo_tag_list').val ''
      $('#todo_title').val ''
      $('.hidden #pending-tags').empty()
      $('[data-toggle="popover"]').popover('hide')
      $('.default-tag-filter').click()
      updateTags()


  # Delete a todo
  $('.todo-list').on 'ajax:success', '.todo-active .todo-delete', (e, data, status, xhr) ->
    $(e.target).closest('tr').remove()
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) - 1)
    updateTags()

  $('.todo-list').on 'ajax:success', '.todo-done .todo-delete', (e, data, status, xhr) ->
    $(e.target).closest('tr').remove()
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) - 1)
    updateTags()


  # Toggle a todo
  $('.todo-list').on 'ajax:success', '.todo-active [data-bip-attribute="completed"]', (e, data, status, xhr) ->
    $(e.target).closest('tr').appendTo('.todo-done tbody').slideDown()
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) - 1)
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) + 1)

  $('.todo-list').on 'ajax:success', '.todo-done [data-bip-attribute="completed"]', (e, data, status, xhr) ->
    $(e.target).closest('tr').appendTo('.todo-active tbody')
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) - 1)
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) + 1)

  $(document).on 'keydown', '#add_tag_field', (e) ->
    if e.which == 13 && $(this).val()
      $('#todo_tag_list').val($('#todo_tag_list').val() + $(this).val() + ', ')
      tag_content = generateTagHtml($(this).val(), true)
      console.log(tag_content)
      $('.popover #pending-tags').prepend(tag_content)
      $('.hidden #pending-tags').prepend(tag_content)
      $(this).val ''

  $('.todo-list').on 'mouseenter', '.todo-title', (e, data, status, xhr) ->
    tags = $(e.target).data('tags').split(', ')
    for tag in tags
      $('.tag-filter').filter(->
          return $(this).text() == tag
        ).find('.label').addClass('label-warning')

  $('.todo-list').on 'mouseleave', '.todo-title', (e, data, status, xhr) ->
      $('.tag-filter .label').removeClass('label-warning')



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

  # Show tags when the page is loaded
  updateTags()


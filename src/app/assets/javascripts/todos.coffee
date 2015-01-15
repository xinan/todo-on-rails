# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  # Activating Best In Place
  $(".best_in_place").best_in_place()

  # Initializing tooltip
  $('[data-toggle="popover"]').popover({
    html: true;
    container: 'body',
    placement: 'bottom',
    content: ->
      return $('#add-tags-popover').html()
  })

  # New todo added
  $('#new_todo').on 'ajax:success', (e, data, status, xhr) ->
    $('.todo-active tbody').prepend(data);
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) + 1)
    $('#todo_tag_list').val ''
    $('#todo_title').val ''
    $('.hidden #pending-tags').empty()
    $('[data-toggle="popover"]').popover('hide')



  # Delete a todo
  $('.todo-active').on 'ajax:success', '.todo-delete', (e, data, status, xhr) ->
    $(e.target).closest('tr').remove()
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) - 1)

  $('.todo-done').on 'ajax:success', '.todo-delete', (e, data, status, xhr) ->
    $(e.target).closest('tr').remove()
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) - 1)


  # Toggle a todo
  $('.todo-active').on 'ajax:success', '[data-bip-attribute="completed"]', (e, data, status, xhr) ->
    $(e.target).closest('tr').appendTo('.todo-done tbody').slideDown()
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) - 1)
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) + 1)

  $('.todo-done').on 'ajax:success', '[data-bip-attribute="completed"]', (e, data, status, xhr) ->
    $(e.target).closest('tr').appendTo('.todo-active tbody')
    $('.todo-done-count').html(parseInt($('.todo-done-count').html()) - 1)
    $('.todo-pending-count').html(parseInt($('.todo-pending-count').html()) + 1)


  $(document).on 'keydown', '#add_tag_field', (e) ->
    if e.which == 13
      $('#todo_tag_list').val($('#todo_tag_list').val() + $(this).val() + ', ')
      tag_content = '<h4><span class="label label-info">' + $(this).val() + '</span></h4>'
      $('.popover #pending-tags').append(tag_content)
      $('.hidden #pending-tags').append(tag_content)
      $(this).val ''


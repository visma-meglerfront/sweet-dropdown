###*
 * SweetDropdown
 * Sweet and versatile jQuery dropdown plugin
 *
 * @author  bluefirex
 * @version  1.0
###
(($) ->
	###*
	 * jQuery Element Binding
	 * Targets a trigger and connects it to a dropdown menu. Allows for chaining.
	 *
	 * @param  {string} method Method to run: attach, detach, show, hide, enable, disable
	 * @param  {mixed}  data   Data for the method
	###
	$.fn.sweetDropdown = (method, data) ->
		switch method
			when 'attach'
				return $(this).attr('data-dropdown', data)
			
			when 'detach'
				return $(this).removeAttr('data-dropdown')
			
			when 'show'
				return $(this).click()
			
			when 'hide'
				$.sweetDropdown.hideAll()
				return $(this)
			
			when 'enable'
				return $(this).removeClass('dropdown-disabled')
			
			when 'disable'
				return $(this).addClass('dropdown-disabled')

	###*
	 * Dummy function as base for the other functions.
	 * Doesnt do ANYTHING.
	###
	$.sweetDropdown = () ->

	###*
	 * Attach all dropdowns to their triggers.
	###
	$.sweetDropdown.attachAll = () ->
		$('body')
			.off('click.dropdown')
			.on('click.dropdown', '[data-dropdown]', showDropdown)

		$('[data-dropdown]')
			.off('click.dropdown')
			.on('click.dropdown', showDropdown)

		$('html, .sweet-modal-content')
			.off('click.dropdown')
			.on('click.dropdown', $.sweetDropdown.hideAll)

		$(window)
			.off('resize.dropdown')
			.on('resize.dropdown', $.sweetDropdown.hideAll)

		return true

	###*
	 * Hide all dropdowns.
	 *
	 * @param  {Event}  e              Native Browser-Event
	 * @param  {string} hideException  ID of a dropdown that should NOT be closed
	###
	$.sweetDropdown.hideAll = (e = null, hideException = null) ->
		targetGroup = if e then $(e.target).parents().addBack() else null

		if targetGroup and targetGroup.hasClass('dropdown-menu') and not targetGroup.is('A')
			return

		el = '.dropdown-menu'
		trigger = '[data-dropdown]'
		hideExceptionID = ''

		if hideException
			hideExceptionID = $(hideException).attr('id')
			
			if not $('[data-dropdown="#' + hideExceptionID + '"]').hasClass('dropdown-open')
				el = '.dropdown-menu:not(#' + hideExceptionID + ')'
				trigger = '[data-dropdown!="#' + hideExceptionID + '"]'

		$('body')
			.find(el)
				.removeClass('dropdown-opened')
				.end()
			.find(trigger)
				.removeClass('dropdown-open')

		animTimeout = window.setTimeout(() ->
			$('body')
				.find(el)
					.hide()
					.end()
		, 200)

		return true

	###*
	 * All possible anchor positions.
	 *
	 * @type {Array}
	###
	$.sweetDropdown.ANCHOR_POSITIONS = [
		'top-left'
		'top-center'
		'top-right'
		'right-top'
		'right-center'
		'right-bottom'
		'bottom-left'
		'bottom-center'
		'bottom-right'
		'left-top'
		'left-center'
		'left-bottom'
	]

	###*
	 * Default settings
	 *
	 * @type {Object}
	###
	$.sweetDropdown.defaults =
		anchorPosition: 'center'

	# Private Stuff

	###*
	 * Show a dropdown. This is triggered by a jQuery click listener.
	 *
	 * @param  {Event} e    Native Browser-Event
	###
	showDropdown = (e = null) ->
		# Gather basic info
		$trigger = $(this)										# TRIGGER
		$dropdown = $($trigger.data('dropdown'))				# DROPDOWN MENU
		$anchor = $dropdown.find('.dropdown-anchor')			# DROPDOWN ANCHOR
		
		hasAnchor = $dropdown.hasClass('dropdown-has-anchor')	# THIS HAS ANCHOR?
		
		isOpen = $trigger.hasClass('dropdown-open')				# IS THIS THING OPEN?
		isDisabled = $trigger.hasClass('dropdown-disabled')		# IS THIS THING DISABLED?
		
		# Gather sizes
		widthDropdown = $dropdown.outerWidth()
		widthTrigger = $trigger.outerWidth()

		heightDropdown = $dropdown.outerHeight()
		heightTrigger = $trigger.outerHeight()

		# Gather positions
		topTrigger = $trigger.position().top
		leftTrigger = $trigger.position().left

		if $trigger.hasClass('dropdown-use-offset')
			topTrigger = $trigger.offset().top
			leftTrigger = $trigger.offset().left

		bottomTrigger = topTrigger + heightTrigger
		rightTrigger = leftTrigger + widthTrigger

		# Cry if dropdown is missing
		if $dropdown.length < 1
			return console.error '[SweetDropdown] Could not find dropdown: ' + $(this).data('dropdown')

		# Create anchor if missing but enabled
		if $anchor.length < 1 and hasAnchor
			$anchor = $('<div class="dropdown-anchor"></div>')
			$dropdown.prepend($anchor)

		# Block event if this is one
		if e isnt undefined
			e.preventDefault()
			e.stopPropagation()

		# Do nothing if disabled or open already
		if isOpen or isDisabled
			return false

		# Hide all those dropdowns
		$.sweetDropdown.hideAll(null, $trigger.data('dropdown'))

		# Get anchor position
		anchorPosition = $.sweetDropdown.defaults.anchorPosition

		for position in $.sweetDropdown.ANCHOR_POSITIONS
			if $dropdown.hasClass('dropdown-anchor-' + position)
				anchorPosition = position

		# Position dropdown!
		top = 0
		left = 0

		# Determine position strings
		positionParts = anchorPosition.split('-')
		anchorSide = positionParts[0]
		anchorPosition = positionParts[1]

		# Top and Bottom share some positions
		if anchorSide is 'top' or anchorSide is 'bottom'
			switch anchorPosition
				when 'left'
					left = leftTrigger

				when 'center'
					left = leftTrigger - widthDropdown / 2 + widthTrigger / 2

				when 'right'
					left = rightTrigger - widthDropdown

		# Left and Right share some positions
		if anchorSide is 'left' or anchorSide is 'right'
			switch anchorPosition
				when 'top'
					top = topTrigger

				when 'center'
					top = topTrigger - heightDropdown / 2 + heightTrigger / 2

				when 'bottom'
					top = topTrigger + heightTrigger - heightDropdown

		# The only differences lie in the opposite-direction positions
		switch anchorSide
			when 'top'
				top = topTrigger + heightTrigger

			when 'right'
				left = leftTrigger - widthDropdown

			when 'bottom'
				top = topTrigger - heightDropdown

			when 'left'
				left = leftTrigger + widthTrigger

		# Add some x/y
		addX = parseInt $dropdown.data('add-x')
		addY = parseInt $dropdown.data('add-y')

		left += addX if not isNaN addX
		top += addY if not isNaN addY

		# Add some anchor x/y
		addAnchorX = parseInt $trigger.data('add-anchor-x')
		addAnchorY = parseInt $trigger.data('add-anchor-y')

		if not isNaN addAnchorX
			$anchor.css(
				marginLeft: addAnchorX
			)

		if not isNaN addAnchorY
			$anchor.css(
				marginTop: addAnchorY
			)

		# Finally show the dropdown
		$dropdown
			.css(
				top: top
				left: left
				display: 'block'
			)

		# Trigger the animation
		window.setTimeout(() ->
			$dropdown.addClass('dropdown-opened')
		, 0)

		# Activate trigger
		$trigger.addClass('dropdown-open')

		return $trigger

	# Auto-attach all dropdowns
	$(() ->
		$.sweetDropdown.attachAll()
	)
)(jQuery)
_ = require 'lodash'

derby = require 'derby'

if not derby.util.isServer
    global.jQuery = $ = require 'jquery'
    require 'bootstrap-datepicker'


module.exports = class
    view: __dirname
    components: [
        class extends require('d-form').DField
            name: 'field'
    ]

    create: ->
        require 'jquery.maskedinput/src/jquery.maskedinput'

        config = @model.get('config') or {}
        @elem.placeholder = $.fn.datepicker.dates['en'].format.replace /\w/g, '_'
        @datepicker = $(@elem).datepicker _.defaults {}, config,
                todayHighlight: true
                autoclose: true
                clearBtn: not @getAttribute 'required'
                orientation: 'auto top'
            .mask $.fn.datepicker.dates['en'].format.replace /\w/g, '9'

        @dom.on 'keyup', @elem, =>
            if @elem.value == @elem.placeholder
                @datepicker.datepicker 'setUTCDate', null

        if @model.get 'value'
            @datepicker.datepicker 'setUTCDate', @model.get 'value'
#        else
#            @model.setDiff 'value', null

        @datepicker.on 'changeDate', (e) =>
            date = @datepicker.datepicker 'getUTCDate'
            if @getAttribute 'endOfDay'
                date?.setUTCHours 23, 59, 59, 999
            return if date?.valueOf() == value?.valueOf()
            @model.set 'value', date
            # value может быть null или undefined

#        @datepicker.on 'clearDate', (e) =>
#            console.log 'picker clear'
#            @model.setDiff 'value', null

        listener = @model.on 'change', 'value', (value) =>
            date = @datepicker.datepicker 'getUTCDate'
            if @getAttribute 'endOfDay'
                date?.setUTCHours 23, 59, 59, 999
            return if value?.valueOf() == date?.valueOf()

            # Обход глюка. Иногда change event вызывается, а само значение устанавливается позже.
            # Из-за этого changeDate и change value начинают бесконечно менять последние два значения местами.
            setTimeout => @datepicker.datepicker 'setUTCDate', value or null
                , 0

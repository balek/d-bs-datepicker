_ = require 'lodash'


module.exports = class
    view: __dirname
    components: [
        class extends require('d-form').DField
            name: 'field'
    ]

    create: ->
        global.jQuery = $ = require 'jquery'
        require 'bootstrap-datepicker'
        require 'bootstrap-datepicker/js/locales/bootstrap-datepicker.ru'
        require 'jquery.maskedinput/src/jquery.maskedinput'

        config = @model.get('config') or {}
        @datepicker = $(@elem).datepicker _.defaults {}, config,
                todayHighlight: true
                autoclose: true
                format: 'dd.mm.yyyy'
                language: 'ru'
                clearBtn: not @getAttribute 'required'
                orientation: 'auto top'
            .mask '99.99.9999'

        @dom.on 'keyup', @elem, =>
            if @elem.value == '__.__.____'
                @datepicker.datepicker 'setDate', null

        if @model.get 'value'
            date = new Date @model.get 'value'
            date.setHours 0, 0, 0, 0
            @datepicker.datepicker 'setDate', date
#        else
#            @model.setDiff 'value', null

        @datepicker.on 'changeDate', (e) =>
            e.date?.setHours 14  # TODO: зависимость от часового пояса
            if e.date or @model.get 'value'
                @model.setDiff 'value', e.date?.getTime() or null
            # value может быть null или undefined

#        @datepicker.on 'clearDate', (e) =>
#            console.log 'picker clear'
#            @model.setDiff 'value', null

        @model.on 'change', 'value', (value) =>
            date = @datepicker.datepicker('getDate')
            date?.setHours 14
            if value != (date?.getTime() or null)
                if value  # Сразу проверяем 0 и пустую строку
                    date = new Date value
                    date?.setHours 0, 0, 0, 0
                else
                    date = null
                # Обход глюка. Иногда change event вызывается, а само значение устанавливается позже.
                # Из-за этого changeDate и change value начинают бесконечно менять последние два значения местами.
                setTimeout => @datepicker.datepicker 'setDate', date
                    , 0

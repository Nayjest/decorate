###*
 * Javascript decorator.
 * Usage examples:
 * <code>
 * var decorator = require('path/to/libs/decorator');
 * decorator.decorateBefore(
 *     MyClass.prototype,
 *     'methodName',
 *     function(){
 *         console.log('methodName call!');
 *     }
 * );
 * </code>
 *
 * @author Vitaliy [Nayjest] Stepanenko <gmail@vitaliy.in>
 ###
define [], ()->
  "use strict"
  FN = Function
  glob = FN('return this')()

  _before = (target, decorator)->
    fn = ()->
      decorator.apply @, arguments
      target.apply @, arguments
    target.decorators = [] unless target.decorators
    target.decorators.push decorator
    fn.prototype = target.prototype
    fn

  _after = (target, decorator)->
    fn = ()->
      res = target.apply @, arguments
      decorator.apply @, arguments
      res
    target.decorators = [] unless target.decorators
    target.decorators.push decorator
    fn.prototype = target.prototype
    fn

  _decorate = (target, decorator, insertAfter) ->
    if insertAfter then _after target, decorator else _before target, decorator


  _method = (obj, methodName, decorator, insertAfter)->
    obj[methodName] = _decorate obj[methodName], decorator, insertAfter

  _methods = (obj, decorator, insertAfter)->
    for key,fn of obj
      if (fn instanceof Function) and obj.hasOwnProperty key
        _method obj, key, decorator, insertAfter
    obj

  ###*
   * Decorates function, decorator runs after function call.
   * Usage:
   *  decorateAfter(<Object targetObj>, <String methodName>, <Function decorator>)
   *  decorateAfter(<Function targetFunc>, <function decorator>)
   *  decorateAfter(<String funcName>, <function decorator>)
   *
   * @param Object|Function|String arg1
   * @param String|Function arg2
   * @param Function|undefined arg3
   * @return Function decorated function.
  ###
  decorate = (a1, a2, a3, a4)->
    switch typeof a1
      when 'object'
        if typeof a2 == 'string'
          _method a1, a2, a3, a4

        else
          _methods a1, a2, a3
      when 'function'
        _decorate a1, a2, a3
      when 'string'
        _method glob, a1, a2, a3

  decorate.after = (a1, a2, a3)->
    if typeof a1 == 'object'
      _method a1, a2, a3, yes
    else
      decorate a1, a2, yes

  decorate.before = (a1, a2, a3)->
    if typeof a1 == 'object'
      _method a1, a2, a3
    else
      decorate a1, a2

  decorate.on = (eventName, handler)->
    decorate.after @, eventName, handler

  decorate.remove = (arg1, arg2, arg3)->
    switch typeof arg1
      when 'object'
        arg1[arg2] = arg1[arg2].prototype.constructor
      when 'function'
        arg1.prototype.constructor
      when 'string'
        glob[arg1] = glob[arg1].prototype.constructor

  decorate

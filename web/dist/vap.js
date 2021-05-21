(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.Vap = factory());
}(this, (function () { 'use strict';

  function _arrayWithHoles(arr) {
    if (Array.isArray(arr)) return arr;
  }

  var arrayWithHoles = _arrayWithHoles;

  function _iterableToArrayLimit(arr, i) {
    if (typeof Symbol === "undefined" || !(Symbol.iterator in Object(arr))) return;
    var _arr = [];
    var _n = true;
    var _d = false;
    var _e = undefined;

    try {
      for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
        _arr.push(_s.value);

        if (i && _arr.length === i) break;
      }
    } catch (err) {
      _d = true;
      _e = err;
    } finally {
      try {
        if (!_n && _i["return"] != null) _i["return"]();
      } finally {
        if (_d) throw _e;
      }
    }

    return _arr;
  }

  var iterableToArrayLimit = _iterableToArrayLimit;

  function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;

    for (var i = 0, arr2 = new Array(len); i < len; i++) {
      arr2[i] = arr[i];
    }

    return arr2;
  }

  var arrayLikeToArray = _arrayLikeToArray;

  function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return arrayLikeToArray(o, minLen);
  }

  var unsupportedIterableToArray = _unsupportedIterableToArray;

  function _nonIterableRest() {
    throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }

  var nonIterableRest = _nonIterableRest;

  function _slicedToArray(arr, i) {
    return arrayWithHoles(arr) || iterableToArrayLimit(arr, i) || unsupportedIterableToArray(arr, i) || nonIterableRest();
  }

  var slicedToArray = _slicedToArray;

  function createCommonjsModule(fn, module) {
  	return module = { exports: {} }, fn(module, module.exports), module.exports;
  }

  var runtime_1 = createCommonjsModule(function (module) {
  /**
   * Copyright (c) 2014-present, Facebook, Inc.
   *
   * This source code is licensed under the MIT license found in the
   * LICENSE file in the root directory of this source tree.
   */

  var runtime = (function (exports) {

    var Op = Object.prototype;
    var hasOwn = Op.hasOwnProperty;
    var undefined$1; // More compressible than void 0.
    var $Symbol = typeof Symbol === "function" ? Symbol : {};
    var iteratorSymbol = $Symbol.iterator || "@@iterator";
    var asyncIteratorSymbol = $Symbol.asyncIterator || "@@asyncIterator";
    var toStringTagSymbol = $Symbol.toStringTag || "@@toStringTag";

    function define(obj, key, value) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
      return obj[key];
    }
    try {
      // IE 8 has a broken Object.defineProperty that only works on DOM objects.
      define({}, "");
    } catch (err) {
      define = function(obj, key, value) {
        return obj[key] = value;
      };
    }

    function wrap(innerFn, outerFn, self, tryLocsList) {
      // If outerFn provided and outerFn.prototype is a Generator, then outerFn.prototype instanceof Generator.
      var protoGenerator = outerFn && outerFn.prototype instanceof Generator ? outerFn : Generator;
      var generator = Object.create(protoGenerator.prototype);
      var context = new Context(tryLocsList || []);

      // The ._invoke method unifies the implementations of the .next,
      // .throw, and .return methods.
      generator._invoke = makeInvokeMethod(innerFn, self, context);

      return generator;
    }
    exports.wrap = wrap;

    // Try/catch helper to minimize deoptimizations. Returns a completion
    // record like context.tryEntries[i].completion. This interface could
    // have been (and was previously) designed to take a closure to be
    // invoked without arguments, but in all the cases we care about we
    // already have an existing method we want to call, so there's no need
    // to create a new function object. We can even get away with assuming
    // the method takes exactly one argument, since that happens to be true
    // in every case, so we don't have to touch the arguments object. The
    // only additional allocation required is the completion record, which
    // has a stable shape and so hopefully should be cheap to allocate.
    function tryCatch(fn, obj, arg) {
      try {
        return { type: "normal", arg: fn.call(obj, arg) };
      } catch (err) {
        return { type: "throw", arg: err };
      }
    }

    var GenStateSuspendedStart = "suspendedStart";
    var GenStateSuspendedYield = "suspendedYield";
    var GenStateExecuting = "executing";
    var GenStateCompleted = "completed";

    // Returning this object from the innerFn has the same effect as
    // breaking out of the dispatch switch statement.
    var ContinueSentinel = {};

    // Dummy constructor functions that we use as the .constructor and
    // .constructor.prototype properties for functions that return Generator
    // objects. For full spec compliance, you may wish to configure your
    // minifier not to mangle the names of these two functions.
    function Generator() {}
    function GeneratorFunction() {}
    function GeneratorFunctionPrototype() {}

    // This is a polyfill for %IteratorPrototype% for environments that
    // don't natively support it.
    var IteratorPrototype = {};
    IteratorPrototype[iteratorSymbol] = function () {
      return this;
    };

    var getProto = Object.getPrototypeOf;
    var NativeIteratorPrototype = getProto && getProto(getProto(values([])));
    if (NativeIteratorPrototype &&
        NativeIteratorPrototype !== Op &&
        hasOwn.call(NativeIteratorPrototype, iteratorSymbol)) {
      // This environment has a native %IteratorPrototype%; use it instead
      // of the polyfill.
      IteratorPrototype = NativeIteratorPrototype;
    }

    var Gp = GeneratorFunctionPrototype.prototype =
      Generator.prototype = Object.create(IteratorPrototype);
    GeneratorFunction.prototype = Gp.constructor = GeneratorFunctionPrototype;
    GeneratorFunctionPrototype.constructor = GeneratorFunction;
    GeneratorFunction.displayName = define(
      GeneratorFunctionPrototype,
      toStringTagSymbol,
      "GeneratorFunction"
    );

    // Helper for defining the .next, .throw, and .return methods of the
    // Iterator interface in terms of a single ._invoke method.
    function defineIteratorMethods(prototype) {
      ["next", "throw", "return"].forEach(function(method) {
        define(prototype, method, function(arg) {
          return this._invoke(method, arg);
        });
      });
    }

    exports.isGeneratorFunction = function(genFun) {
      var ctor = typeof genFun === "function" && genFun.constructor;
      return ctor
        ? ctor === GeneratorFunction ||
          // For the native GeneratorFunction constructor, the best we can
          // do is to check its .name property.
          (ctor.displayName || ctor.name) === "GeneratorFunction"
        : false;
    };

    exports.mark = function(genFun) {
      if (Object.setPrototypeOf) {
        Object.setPrototypeOf(genFun, GeneratorFunctionPrototype);
      } else {
        genFun.__proto__ = GeneratorFunctionPrototype;
        define(genFun, toStringTagSymbol, "GeneratorFunction");
      }
      genFun.prototype = Object.create(Gp);
      return genFun;
    };

    // Within the body of any async function, `await x` is transformed to
    // `yield regeneratorRuntime.awrap(x)`, so that the runtime can test
    // `hasOwn.call(value, "__await")` to determine if the yielded value is
    // meant to be awaited.
    exports.awrap = function(arg) {
      return { __await: arg };
    };

    function AsyncIterator(generator, PromiseImpl) {
      function invoke(method, arg, resolve, reject) {
        var record = tryCatch(generator[method], generator, arg);
        if (record.type === "throw") {
          reject(record.arg);
        } else {
          var result = record.arg;
          var value = result.value;
          if (value &&
              typeof value === "object" &&
              hasOwn.call(value, "__await")) {
            return PromiseImpl.resolve(value.__await).then(function(value) {
              invoke("next", value, resolve, reject);
            }, function(err) {
              invoke("throw", err, resolve, reject);
            });
          }

          return PromiseImpl.resolve(value).then(function(unwrapped) {
            // When a yielded Promise is resolved, its final value becomes
            // the .value of the Promise<{value,done}> result for the
            // current iteration.
            result.value = unwrapped;
            resolve(result);
          }, function(error) {
            // If a rejected Promise was yielded, throw the rejection back
            // into the async generator function so it can be handled there.
            return invoke("throw", error, resolve, reject);
          });
        }
      }

      var previousPromise;

      function enqueue(method, arg) {
        function callInvokeWithMethodAndArg() {
          return new PromiseImpl(function(resolve, reject) {
            invoke(method, arg, resolve, reject);
          });
        }

        return previousPromise =
          // If enqueue has been called before, then we want to wait until
          // all previous Promises have been resolved before calling invoke,
          // so that results are always delivered in the correct order. If
          // enqueue has not been called before, then it is important to
          // call invoke immediately, without waiting on a callback to fire,
          // so that the async generator function has the opportunity to do
          // any necessary setup in a predictable way. This predictability
          // is why the Promise constructor synchronously invokes its
          // executor callback, and why async functions synchronously
          // execute code before the first await. Since we implement simple
          // async functions in terms of async generators, it is especially
          // important to get this right, even though it requires care.
          previousPromise ? previousPromise.then(
            callInvokeWithMethodAndArg,
            // Avoid propagating failures to Promises returned by later
            // invocations of the iterator.
            callInvokeWithMethodAndArg
          ) : callInvokeWithMethodAndArg();
      }

      // Define the unified helper method that is used to implement .next,
      // .throw, and .return (see defineIteratorMethods).
      this._invoke = enqueue;
    }

    defineIteratorMethods(AsyncIterator.prototype);
    AsyncIterator.prototype[asyncIteratorSymbol] = function () {
      return this;
    };
    exports.AsyncIterator = AsyncIterator;

    // Note that simple async functions are implemented on top of
    // AsyncIterator objects; they just return a Promise for the value of
    // the final result produced by the iterator.
    exports.async = function(innerFn, outerFn, self, tryLocsList, PromiseImpl) {
      if (PromiseImpl === void 0) PromiseImpl = Promise;

      var iter = new AsyncIterator(
        wrap(innerFn, outerFn, self, tryLocsList),
        PromiseImpl
      );

      return exports.isGeneratorFunction(outerFn)
        ? iter // If outerFn is a generator, return the full iterator.
        : iter.next().then(function(result) {
            return result.done ? result.value : iter.next();
          });
    };

    function makeInvokeMethod(innerFn, self, context) {
      var state = GenStateSuspendedStart;

      return function invoke(method, arg) {
        if (state === GenStateExecuting) {
          throw new Error("Generator is already running");
        }

        if (state === GenStateCompleted) {
          if (method === "throw") {
            throw arg;
          }

          // Be forgiving, per 25.3.3.3.3 of the spec:
          // https://people.mozilla.org/~jorendorff/es6-draft.html#sec-generatorresume
          return doneResult();
        }

        context.method = method;
        context.arg = arg;

        while (true) {
          var delegate = context.delegate;
          if (delegate) {
            var delegateResult = maybeInvokeDelegate(delegate, context);
            if (delegateResult) {
              if (delegateResult === ContinueSentinel) continue;
              return delegateResult;
            }
          }

          if (context.method === "next") {
            // Setting context._sent for legacy support of Babel's
            // function.sent implementation.
            context.sent = context._sent = context.arg;

          } else if (context.method === "throw") {
            if (state === GenStateSuspendedStart) {
              state = GenStateCompleted;
              throw context.arg;
            }

            context.dispatchException(context.arg);

          } else if (context.method === "return") {
            context.abrupt("return", context.arg);
          }

          state = GenStateExecuting;

          var record = tryCatch(innerFn, self, context);
          if (record.type === "normal") {
            // If an exception is thrown from innerFn, we leave state ===
            // GenStateExecuting and loop back for another invocation.
            state = context.done
              ? GenStateCompleted
              : GenStateSuspendedYield;

            if (record.arg === ContinueSentinel) {
              continue;
            }

            return {
              value: record.arg,
              done: context.done
            };

          } else if (record.type === "throw") {
            state = GenStateCompleted;
            // Dispatch the exception by looping back around to the
            // context.dispatchException(context.arg) call above.
            context.method = "throw";
            context.arg = record.arg;
          }
        }
      };
    }

    // Call delegate.iterator[context.method](context.arg) and handle the
    // result, either by returning a { value, done } result from the
    // delegate iterator, or by modifying context.method and context.arg,
    // setting context.delegate to null, and returning the ContinueSentinel.
    function maybeInvokeDelegate(delegate, context) {
      var method = delegate.iterator[context.method];
      if (method === undefined$1) {
        // A .throw or .return when the delegate iterator has no .throw
        // method always terminates the yield* loop.
        context.delegate = null;

        if (context.method === "throw") {
          // Note: ["return"] must be used for ES3 parsing compatibility.
          if (delegate.iterator["return"]) {
            // If the delegate iterator has a return method, give it a
            // chance to clean up.
            context.method = "return";
            context.arg = undefined$1;
            maybeInvokeDelegate(delegate, context);

            if (context.method === "throw") {
              // If maybeInvokeDelegate(context) changed context.method from
              // "return" to "throw", let that override the TypeError below.
              return ContinueSentinel;
            }
          }

          context.method = "throw";
          context.arg = new TypeError(
            "The iterator does not provide a 'throw' method");
        }

        return ContinueSentinel;
      }

      var record = tryCatch(method, delegate.iterator, context.arg);

      if (record.type === "throw") {
        context.method = "throw";
        context.arg = record.arg;
        context.delegate = null;
        return ContinueSentinel;
      }

      var info = record.arg;

      if (! info) {
        context.method = "throw";
        context.arg = new TypeError("iterator result is not an object");
        context.delegate = null;
        return ContinueSentinel;
      }

      if (info.done) {
        // Assign the result of the finished delegate to the temporary
        // variable specified by delegate.resultName (see delegateYield).
        context[delegate.resultName] = info.value;

        // Resume execution at the desired location (see delegateYield).
        context.next = delegate.nextLoc;

        // If context.method was "throw" but the delegate handled the
        // exception, let the outer generator proceed normally. If
        // context.method was "next", forget context.arg since it has been
        // "consumed" by the delegate iterator. If context.method was
        // "return", allow the original .return call to continue in the
        // outer generator.
        if (context.method !== "return") {
          context.method = "next";
          context.arg = undefined$1;
        }

      } else {
        // Re-yield the result returned by the delegate method.
        return info;
      }

      // The delegate iterator is finished, so forget it and continue with
      // the outer generator.
      context.delegate = null;
      return ContinueSentinel;
    }

    // Define Generator.prototype.{next,throw,return} in terms of the
    // unified ._invoke helper method.
    defineIteratorMethods(Gp);

    define(Gp, toStringTagSymbol, "Generator");

    // A Generator should always return itself as the iterator object when the
    // @@iterator function is called on it. Some browsers' implementations of the
    // iterator prototype chain incorrectly implement this, causing the Generator
    // object to not be returned from this call. This ensures that doesn't happen.
    // See https://github.com/facebook/regenerator/issues/274 for more details.
    Gp[iteratorSymbol] = function() {
      return this;
    };

    Gp.toString = function() {
      return "[object Generator]";
    };

    function pushTryEntry(locs) {
      var entry = { tryLoc: locs[0] };

      if (1 in locs) {
        entry.catchLoc = locs[1];
      }

      if (2 in locs) {
        entry.finallyLoc = locs[2];
        entry.afterLoc = locs[3];
      }

      this.tryEntries.push(entry);
    }

    function resetTryEntry(entry) {
      var record = entry.completion || {};
      record.type = "normal";
      delete record.arg;
      entry.completion = record;
    }

    function Context(tryLocsList) {
      // The root entry object (effectively a try statement without a catch
      // or a finally block) gives us a place to store values thrown from
      // locations where there is no enclosing try statement.
      this.tryEntries = [{ tryLoc: "root" }];
      tryLocsList.forEach(pushTryEntry, this);
      this.reset(true);
    }

    exports.keys = function(object) {
      var keys = [];
      for (var key in object) {
        keys.push(key);
      }
      keys.reverse();

      // Rather than returning an object with a next method, we keep
      // things simple and return the next function itself.
      return function next() {
        while (keys.length) {
          var key = keys.pop();
          if (key in object) {
            next.value = key;
            next.done = false;
            return next;
          }
        }

        // To avoid creating an additional object, we just hang the .value
        // and .done properties off the next function object itself. This
        // also ensures that the minifier will not anonymize the function.
        next.done = true;
        return next;
      };
    };

    function values(iterable) {
      if (iterable) {
        var iteratorMethod = iterable[iteratorSymbol];
        if (iteratorMethod) {
          return iteratorMethod.call(iterable);
        }

        if (typeof iterable.next === "function") {
          return iterable;
        }

        if (!isNaN(iterable.length)) {
          var i = -1, next = function next() {
            while (++i < iterable.length) {
              if (hasOwn.call(iterable, i)) {
                next.value = iterable[i];
                next.done = false;
                return next;
              }
            }

            next.value = undefined$1;
            next.done = true;

            return next;
          };

          return next.next = next;
        }
      }

      // Return an iterator with no values.
      return { next: doneResult };
    }
    exports.values = values;

    function doneResult() {
      return { value: undefined$1, done: true };
    }

    Context.prototype = {
      constructor: Context,

      reset: function(skipTempReset) {
        this.prev = 0;
        this.next = 0;
        // Resetting context._sent for legacy support of Babel's
        // function.sent implementation.
        this.sent = this._sent = undefined$1;
        this.done = false;
        this.delegate = null;

        this.method = "next";
        this.arg = undefined$1;

        this.tryEntries.forEach(resetTryEntry);

        if (!skipTempReset) {
          for (var name in this) {
            // Not sure about the optimal order of these conditions:
            if (name.charAt(0) === "t" &&
                hasOwn.call(this, name) &&
                !isNaN(+name.slice(1))) {
              this[name] = undefined$1;
            }
          }
        }
      },

      stop: function() {
        this.done = true;

        var rootEntry = this.tryEntries[0];
        var rootRecord = rootEntry.completion;
        if (rootRecord.type === "throw") {
          throw rootRecord.arg;
        }

        return this.rval;
      },

      dispatchException: function(exception) {
        if (this.done) {
          throw exception;
        }

        var context = this;
        function handle(loc, caught) {
          record.type = "throw";
          record.arg = exception;
          context.next = loc;

          if (caught) {
            // If the dispatched exception was caught by a catch block,
            // then let that catch block handle the exception normally.
            context.method = "next";
            context.arg = undefined$1;
          }

          return !! caught;
        }

        for (var i = this.tryEntries.length - 1; i >= 0; --i) {
          var entry = this.tryEntries[i];
          var record = entry.completion;

          if (entry.tryLoc === "root") {
            // Exception thrown outside of any try block that could handle
            // it, so set the completion value of the entire function to
            // throw the exception.
            return handle("end");
          }

          if (entry.tryLoc <= this.prev) {
            var hasCatch = hasOwn.call(entry, "catchLoc");
            var hasFinally = hasOwn.call(entry, "finallyLoc");

            if (hasCatch && hasFinally) {
              if (this.prev < entry.catchLoc) {
                return handle(entry.catchLoc, true);
              } else if (this.prev < entry.finallyLoc) {
                return handle(entry.finallyLoc);
              }

            } else if (hasCatch) {
              if (this.prev < entry.catchLoc) {
                return handle(entry.catchLoc, true);
              }

            } else if (hasFinally) {
              if (this.prev < entry.finallyLoc) {
                return handle(entry.finallyLoc);
              }

            } else {
              throw new Error("try statement without catch or finally");
            }
          }
        }
      },

      abrupt: function(type, arg) {
        for (var i = this.tryEntries.length - 1; i >= 0; --i) {
          var entry = this.tryEntries[i];
          if (entry.tryLoc <= this.prev &&
              hasOwn.call(entry, "finallyLoc") &&
              this.prev < entry.finallyLoc) {
            var finallyEntry = entry;
            break;
          }
        }

        if (finallyEntry &&
            (type === "break" ||
             type === "continue") &&
            finallyEntry.tryLoc <= arg &&
            arg <= finallyEntry.finallyLoc) {
          // Ignore the finally entry if control is not jumping to a
          // location outside the try/catch block.
          finallyEntry = null;
        }

        var record = finallyEntry ? finallyEntry.completion : {};
        record.type = type;
        record.arg = arg;

        if (finallyEntry) {
          this.method = "next";
          this.next = finallyEntry.finallyLoc;
          return ContinueSentinel;
        }

        return this.complete(record);
      },

      complete: function(record, afterLoc) {
        if (record.type === "throw") {
          throw record.arg;
        }

        if (record.type === "break" ||
            record.type === "continue") {
          this.next = record.arg;
        } else if (record.type === "return") {
          this.rval = this.arg = record.arg;
          this.method = "return";
          this.next = "end";
        } else if (record.type === "normal" && afterLoc) {
          this.next = afterLoc;
        }

        return ContinueSentinel;
      },

      finish: function(finallyLoc) {
        for (var i = this.tryEntries.length - 1; i >= 0; --i) {
          var entry = this.tryEntries[i];
          if (entry.finallyLoc === finallyLoc) {
            this.complete(entry.completion, entry.afterLoc);
            resetTryEntry(entry);
            return ContinueSentinel;
          }
        }
      },

      "catch": function(tryLoc) {
        for (var i = this.tryEntries.length - 1; i >= 0; --i) {
          var entry = this.tryEntries[i];
          if (entry.tryLoc === tryLoc) {
            var record = entry.completion;
            if (record.type === "throw") {
              var thrown = record.arg;
              resetTryEntry(entry);
            }
            return thrown;
          }
        }

        // The context.catch method must only be called with a location
        // argument that corresponds to a known catch block.
        throw new Error("illegal catch attempt");
      },

      delegateYield: function(iterable, resultName, nextLoc) {
        this.delegate = {
          iterator: values(iterable),
          resultName: resultName,
          nextLoc: nextLoc
        };

        if (this.method === "next") {
          // Deliberately forget the last sent value so that we don't
          // accidentally pass it on to the delegate.
          this.arg = undefined$1;
        }

        return ContinueSentinel;
      }
    };

    // Regardless of whether this script is executing as a CommonJS module
    // or not, return the runtime object so that we can declare the variable
    // regeneratorRuntime in the outer scope, which allows this module to be
    // injected easily by `bin/regenerator --include-runtime script.js`.
    return exports;

  }(
    // If this script is executing as a CommonJS module, use module.exports
    // as the regeneratorRuntime namespace. Otherwise create a new empty
    // object. Either way, the resulting object will be used to initialize
    // the regeneratorRuntime variable at the top of this file.
     module.exports 
  ));

  try {
    regeneratorRuntime = runtime;
  } catch (accidentalStrictMode) {
    // This module should not be running in strict mode, so the above
    // assignment should always work unless something is misconfigured. Just
    // in case runtime.js accidentally runs in strict mode, we can escape
    // strict mode using a global Function call. This could conceivably fail
    // if a Content Security Policy forbids using Function, but in that case
    // the proper solution is to fix the accidental strict mode problem. If
    // you've misconfigured your bundler to force strict mode and applied a
    // CSP to forbid Function, and you're not willing to fix either of those
    // problems, please detail your unique predicament in a GitHub issue.
    Function("r", "regeneratorRuntime = r")(runtime);
  }
  });

  var D__project_vapSource_web_node_modules__babel_runtime_regenerator = runtime_1;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var classCallCheck = _classCallCheck;

  function _defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      descriptor.enumerable = descriptor.enumerable || false;
      descriptor.configurable = true;
      if ("value" in descriptor) descriptor.writable = true;
      Object.defineProperty(target, descriptor.key, descriptor);
    }
  }

  function _createClass(Constructor, protoProps, staticProps) {
    if (protoProps) _defineProperties(Constructor.prototype, protoProps);
    if (staticProps) _defineProperties(Constructor, staticProps);
    return Constructor;
  }

  var createClass = _createClass;

  var getPrototypeOf = createCommonjsModule(function (module) {
  function _getPrototypeOf(o) {
    module.exports = _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) {
      return o.__proto__ || Object.getPrototypeOf(o);
    };
    return _getPrototypeOf(o);
  }

  module.exports = _getPrototypeOf;
  });

  function _superPropBase(object, property) {
    while (!Object.prototype.hasOwnProperty.call(object, property)) {
      object = getPrototypeOf(object);
      if (object === null) break;
    }

    return object;
  }

  var superPropBase = _superPropBase;

  var get = createCommonjsModule(function (module) {
  function _get(target, property, receiver) {
    if (typeof Reflect !== "undefined" && Reflect.get) {
      module.exports = _get = Reflect.get;
    } else {
      module.exports = _get = function _get(target, property, receiver) {
        var base = superPropBase(target, property);
        if (!base) return;
        var desc = Object.getOwnPropertyDescriptor(base, property);

        if (desc.get) {
          return desc.get.call(receiver);
        }

        return desc.value;
      };
    }

    return _get(target, property, receiver || target);
  }

  module.exports = _get;
  });

  var setPrototypeOf = createCommonjsModule(function (module) {
  function _setPrototypeOf(o, p) {
    module.exports = _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) {
      o.__proto__ = p;
      return o;
    };

    return _setPrototypeOf(o, p);
  }

  module.exports = _setPrototypeOf;
  });

  function _inherits(subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function");
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        writable: true,
        configurable: true
      }
    });
    if (superClass) setPrototypeOf(subClass, superClass);
  }

  var inherits = _inherits;

  var _typeof_1 = createCommonjsModule(function (module) {
  function _typeof(obj) {
    "@babel/helpers - typeof";

    if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") {
      module.exports = _typeof = function _typeof(obj) {
        return typeof obj;
      };
    } else {
      module.exports = _typeof = function _typeof(obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
      };
    }

    return _typeof(obj);
  }

  module.exports = _typeof;
  });

  function _assertThisInitialized(self) {
    if (self === void 0) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return self;
  }

  var assertThisInitialized = _assertThisInitialized;

  function _possibleConstructorReturn(self, call) {
    if (call && (_typeof_1(call) === "object" || typeof call === "function")) {
      return call;
    }

    return assertThisInitialized(self);
  }

  var possibleConstructorReturn = _possibleConstructorReturn;

  var getPrototypeOf$1 = createCommonjsModule(function (module) {
  function _getPrototypeOf(o) {
    module.exports = _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) {
      return o.__proto__ || Object.getPrototypeOf(o);
    };
    return _getPrototypeOf(o);
  }

  module.exports = _getPrototypeOf;
  });

  /*! *****************************************************************************
  Copyright (c) Microsoft Corporation.

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
  INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
  LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  PERFORMANCE OF THIS SOFTWARE.
  ***************************************************************************** */

  function __awaiter(thisArg, _arguments, P, generator) {
      function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
      return new (P || (P = Promise))(function (resolve, reject) {
          function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
          function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
          function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
          step((generator = generator.apply(thisArg, _arguments || [])).next());
      });
  }

  /*
   * Tencent is pleased to support the open source community by making vap available.
   *
   * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
   *
   * Licensed under the MIT License (the "License"); you may not use this file except in
   * compliance with the License. You may obtain a copy of the License at
   *
   * http://opensource.org/licenses/MIT
   *
   * Unless required by applicable law or agreed to in writing, software distributed under the License is
   * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
   * either express or implied. See the License for the specific language governing permissions and
   * limitations under the License.
   */

  var FrameParser = /*#__PURE__*/function () {
    function FrameParser(source, headData) {
      classCallCheck(this, FrameParser);

      this.config = source || {};
      this.headData = headData;
      this.frame = [];
      this.textureMap = {};
    }

    createClass(FrameParser, [{
      key: "init",
      value: function init() {
        return __awaiter(this, void 0, void 0, /*#__PURE__*/D__project_vapSource_web_node_modules__babel_runtime_regenerator.mark(function _callee() {
          return D__project_vapSource_web_node_modules__babel_runtime_regenerator.wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  this.initCanvas(); // 判断是url还是json对象

                  if (!/\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\.json$/.test(this.config)) {
                    _context.next = 5;
                    break;
                  }

                  _context.next = 4;
                  return this.getConfigBySrc(this.config);

                case 4:
                  this.config = _context.sent;

                case 5:
                  _context.next = 7;
                  return this.parseSrc(this.config);

                case 7:
                  this.canvas.parentNode.removeChild(this.canvas);
                  this.frame = this.config.frame || [];
                  return _context.abrupt("return", this);

                case 10:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, this);
        }));
      }
    }, {
      key: "initCanvas",
      value: function initCanvas() {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        canvas.style.display = 'none';
        document.body.appendChild(canvas);
        this.ctx = ctx;
        this.canvas = canvas;
      }
    }, {
      key: "loadImg",
      value: function loadImg(url) {
        return new Promise(function (resolve, reject) {
          // console.log('load img:', url)
          var img = new Image();
          img.crossOrigin = 'anonymous';

          img.onload = function () {
            resolve(this);
          };

          img.onerror = function (e) {
            console.error('frame 资源加载失败:' + url);
            reject(new Error('frame 资源加载失败:' + url));
          };

          img.src = url;
        });
      }
    }, {
      key: "parseSrc",
      value: function parseSrc(dataJson) {
        var _this = this;

        var src = this.srcData = {};
        return Promise.all((dataJson.src || []).map(function (item) {
          return __awaiter(_this, void 0, void 0, /*#__PURE__*/D__project_vapSource_web_node_modules__babel_runtime_regenerator.mark(function _callee2() {
            var _this2 = this;

            return D__project_vapSource_web_node_modules__babel_runtime_regenerator.wrap(function _callee2$(_context2) {
              while (1) {
                switch (_context2.prev = _context2.next) {
                  case 0:
                    item.img = null;

                    if (this.headData[item.srcTag.slice(1, item.srcTag.length - 1)]) {
                      _context2.next = 5;
                      break;
                    }

                    console.warn("vap: \u878D\u5408\u4FE1\u606F\u6CA1\u6709\u4F20\u5165\uFF1A".concat(item.srcTag));
                    _context2.next = 21;
                    break;

                  case 5:
                    if (!(item.srcType === 'txt')) {
                      _context2.next = 10;
                      break;
                    }

                    item.textStr = item.srcTag.replace(/\[(.*)\]/, function ($0, $1) {
                      return _this2.headData[$1];
                    });
                    item.img = this.makeTextImg(item);
                    _context2.next = 20;
                    break;

                  case 10:
                    if (!(item.srcType === 'img')) {
                      _context2.next = 20;
                      break;
                    }

                    item.imgUrl = item.srcTag.replace(/\[(.*)\]/, function ($0, $1) {
                      return _this2.headData[$1];
                    });
                    _context2.prev = 12;
                    _context2.next = 15;
                    return this.loadImg(item.imgUrl + '?t=' + Date.now());

                  case 15:
                    item.img = _context2.sent;
                    _context2.next = 20;
                    break;

                  case 18:
                    _context2.prev = 18;
                    _context2.t0 = _context2["catch"](12);

                  case 20:
                    if (item.img) {
                      src[item.srcId] = item;
                    }

                  case 21:
                  case "end":
                    return _context2.stop();
                }
              }
            }, _callee2, this, [[12, 18]]);
          }));
        }));
      }
      /**
       * 下载json文件
       * @param jsonUrl json外链
       * @returns {Promise}
       */

    }, {
      key: "getConfigBySrc",
      value: function getConfigBySrc(jsonUrl) {
        return new Promise(function (resolve, reject) {
          var xhr = new XMLHttpRequest();
          xhr.open("GET", jsonUrl, true);
          xhr.responseType = "json";

          xhr.onload = function () {
            if (xhr.status === 200 || xhr.status === 304 && xhr.response) {
              var res = xhr.response;
              resolve(res);
            } else {
              reject(new Error("http response invalid" + xhr.status));
            }
          };

          xhr.send();
        });
      }
      /**
       * 文字转换图片
       * @param {*} param0
       */

    }, {
      key: "makeTextImg",
      value: function makeTextImg(_ref) {
        var textStr = _ref.textStr,
            w = _ref.w,
            h = _ref.h,
            color = _ref.color,
            style = _ref.style;
        var ctx = this.ctx;
        ctx.canvas.width = w;
        ctx.canvas.height = h;
        var fontSize = Math.min(w / textStr.length, h - 8); // 需留一定间隙

        var font = ["".concat(fontSize, "px"), 'Arial'];

        if (style === 'b') {
          font.unshift('bold');
        }

        ctx.font = font.join(' ');
        ctx.textBaseline = 'middle';
        ctx.textAlign = 'center';
        ctx.fillStyle = color;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        ctx.fillText(textStr, w / 2, h / 2); // console.log('frame : ' + textStr, ctx.canvas.toDataURL('image/png'))

        return ctx.getImageData(0, 0, w, h);
      }
    }, {
      key: "getFrame",
      value: function getFrame(frame) {
        return this.frame.find(function (item) {
          return item.i === frame;
        });
      }
    }]);

    return FrameParser;
  }();

  /*
   * Tencent is pleased to support the open source community by making vap available.
   *
   * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
   *
   * Licensed under the MIT License (the "License"); you may not use this file except in
   * compliance with the License. You may obtain a copy of the License at
   *
   * http://opensource.org/licenses/MIT
   *
   * Unless required by applicable law or agreed to in writing, software distributed under the License is
   * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
   * either express or implied. See the License for the specific language governing permissions and
   * limitations under the License.
   */
  function createShader(gl, type, source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader); // if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    //     console.error(gl.getShaderInfoLog(shader))
    // }

    return shader;
  }
  function createProgram(gl, vertexShader, fragmentShader) {
    var program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program); // if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    //     console.error(gl.getProgramInfoLog(program))
    // }

    gl.useProgram(program);
    return program;
  }
  function createTexture(gl, index, imgData) {
    var texture = gl.createTexture();
    var textrueIndex = gl.TEXTURE0 + index;
    gl.activeTexture(textrueIndex);
    gl.bindTexture(gl.TEXTURE_2D, texture); // gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

    if (imgData) {
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imgData);
    }

    return texture;
  }

  var VapVideo = /*#__PURE__*/function () {
    function VapVideo(options) {
      classCallCheck(this, VapVideo);

      if (!options.container || !options.src) {
        console.warn('[Alpha video]: options container and src cannot be empty!');
      }

      this.options = Object.assign({
        // 视频url
        src: '',
        // 循环播放
        loop: false,
        fps: 20,
        // 视频宽度
        width: 375,
        // 视频高度
        height: 375,
        // 容器
        container: null,
        // 是否预加载视频资源
        precache: false,
        // 是否静音播放
        mute: false,
        config: ''
      }, options);
      this.fps = 20;
      this.setBegin = true;
      this.requestAnim = this.requestAnimFunc();
      this.container = this.options.container;

      if (!this.options.src || !this.options.config || !this.options.container) {
        console.error('参数出错：src(视频地址)、config(配置文件地址)、container(dom容器)');
      } else {
        // 创建video
        this.initVideo();
      }
    }

    createClass(VapVideo, [{
      key: "precacheSource",
      value: function precacheSource(source) {
        var URL = window.webkitURL || window.URL;
        return new Promise(function (resolve, reject) {
          var xhr = new XMLHttpRequest();
          xhr.open("GET", source, true);
          xhr.responseType = "blob";

          xhr.onload = function () {
            if (xhr.status === 200 || xhr.status === 304) {
              var res = xhr.response;

              if (/iphone|ipad|ipod/i.test(navigator.userAgent)) {
                var fileReader = new FileReader();

                fileReader.onloadend = function () {
                  var resultStr = fileReader.result;
                  var raw = atob(resultStr.slice(resultStr.indexOf(",") + 1));
                  var buf = Array(raw.length);

                  for (var d = 0; d < raw.length; d++) {
                    buf[d] = raw.charCodeAt(d);
                  }

                  var arr = new Uint8Array(buf);
                  var blob = new Blob([arr], {
                    type: "video/mp4"
                  });
                  resolve(URL.createObjectURL(blob));
                };

                fileReader.readAsDataURL(xhr.response);
              } else {
                resolve(URL.createObjectURL(res));
              }
            } else {
              reject(new Error("http response invalid" + xhr.status));
            }
          };

          xhr.send();
        });
      }
    }, {
      key: "initVideo",
      value: function initVideo() {
        var _this = this;

        var options = this.options; // 创建video

        var video = this.video = document.createElement('video');
        video.crossOrigin = 'anonymous';
        video.autoplay = false;
        video.preload = 'auto';
        video.setAttribute('playsinline', '');
        video.setAttribute('webkit-playsinline', '');

        if (options.mute) {
          video.muted = true;
          video.volume = 0;
        }

        video.style.display = 'none';
        video.loop = !!options.loop;

        if (options.precache) {
          this.precacheSource(options.src).then(function (blob) {
            console.log("sample precached.");
            video.src = blob;
            document.body.appendChild(video);
          })["catch"](function (e) {
            console.error(e);
          });
        } else {
          video.src = options.src; // 这里要插在body上，避免container移动带来无法播放的问题

          document.body.appendChild(this.video);
          video.load();
        } // 绑定事件


        this.events = {};
        ['playing', 'pause', 'ended', 'error', 'canplay'].forEach(function (item) {
          _this.on(item, _this['on' + item].bind(_this));
        });
      }
    }, {
      key: "drawFrame",
      value: function drawFrame() {
        this._drawFrame = this._drawFrame || this.drawFrame.bind(this);
        this.animId = this.requestAnim(this._drawFrame);
      }
    }, {
      key: "play",
      value: function play() {
        var _this2 = this;

        var prom = this.video && this.video.play();

        if (prom && prom.then) {
          prom["catch"](function (e) {
            if (!_this2.video) {
              return;
            }

            _this2.video.muted = true;
            _this2.video.volume = 0;

            _this2.video.play()["catch"](function (e) {
              (_this2.events.error || []).forEach(function (item) {
                item(e);
              });
            });
          });
        }
      }
    }, {
      key: "pause",
      value: function pause() {
        this.video && this.video.pause();
      }
    }, {
      key: "setTime",
      value: function setTime(t) {
        if (this.video) {
          this.video.currentTime = t;
        }
      }
    }, {
      key: "requestAnimFunc",
      value: function requestAnimFunc() {
        var me = this;

        if (window.requestAnimationFrame) {
          var index = -1;
          return function (cb) {
            index++;
            return requestAnimationFrame(function () {
              if (!(index % (60 / me.fps))) {
                return cb();
              }

              me.animId = me.requestAnim(cb);
            });
          };
        }

        return function (cb) {
          return setTimeout(cb, 1000 / me.fps);
        };
      }
    }, {
      key: "cancelRequestAnimation",
      value: function cancelRequestAnimation() {
        if (window.cancelAnimationFrame) {
          cancelAnimationFrame(this.animId);
        }

        clearTimeout(this.animId);
      }
    }, {
      key: "destroy",
      value: function destroy() {
        if (this.video) {
          this.video.parentNode && this.video.parentNode.removeChild(this.video);
          this.video = null;
        }

        this.cancelRequestAnimation();
        this.options.onDestory && this.options.onDestory();
      }
    }, {
      key: "clear",
      value: function clear() {
        this.destroy();
      }
    }, {
      key: "on",
      value: function on(event, callback) {
        var cbs = this.events[event] || [];
        cbs.push(callback);
        this.events[event] = cbs;
        this.video.addEventListener(event, callback);
        return this;
      }
    }, {
      key: "onplaying",
      value: function onplaying() {
        if (!this.firstPlaying) {
          this.firstPlaying = true;
          this.drawFrame();
        }
      }
    }, {
      key: "onpause",
      value: function onpause() {}
    }, {
      key: "onended",
      value: function onended() {
        this.destroy();
      }
    }, {
      key: "oncanplay",
      value: function oncanplay() {
        var begin = this.options.beginPoint;

        if (begin && this.setBegin) {
          this.setBegin = false;
          this.video.currentTime = begin;
        }
      }
    }, {
      key: "onerror",
      value: function onerror(err) {
        console.error('[Alpha video]: play error: ', err);
        this.destroy();
        this.options.onLoadError && this.options.onLoadError(err);
      }
    }]);

    return VapVideo;
  }();

  function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = getPrototypeOf$1(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = getPrototypeOf$1(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return possibleConstructorReturn(this, result); }; }

  function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }
  var clearTimer = null;
  var instances = {};
  var PER_SIZE = 9;

  function computeCoord(x, y, w, h, vw, vh) {
    // leftX rightX bottomY topY
    return [x / vw, (x + w) / vw, (vh - y - h) / vh, (vh - y) / vh];
  }

  var WebglRenderVap = /*#__PURE__*/function (_VapVideo) {
    inherits(WebglRenderVap, _VapVideo);

    var _super = _createSuper(WebglRenderVap);

    function WebglRenderVap(options) {
      var _this;

      classCallCheck(this, WebglRenderVap);

      _this = _super.call(this, options);
      _this.insType = _this.options.type;

      if (instances[_this.insType]) {
        _this.instance = instances[_this.insType];
      } else {
        _this.instance = instances[_this.insType] = {};
      }

      _this.textures = [];
      _this.buffers = [];
      _this.shaders = [];

      _this.init();

      return _this;
    }

    createClass(WebglRenderVap, [{
      key: "init",
      value: function init() {
        return __awaiter(this, void 0, void 0, /*#__PURE__*/D__project_vapSource_web_node_modules__babel_runtime_regenerator.mark(function _callee() {
          return D__project_vapSource_web_node_modules__babel_runtime_regenerator.wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  this.setCanvas();

                  if (!this.options.config) {
                    _context.next = 12;
                    break;
                  }

                  _context.prev = 2;
                  _context.next = 5;
                  return new FrameParser(this.options.config, this.options).init();

                case 5:
                  this.vapFrameParser = _context.sent;
                  this.resources = this.vapFrameParser.srcData;
                  _context.next = 12;
                  break;

                case 9:
                  _context.prev = 9;
                  _context.t0 = _context["catch"](2);
                  console.error('[Alpha video] parse vap frame error.', _context.t0);

                case 12:
                  this.resources = this.resources || {};
                  this.initWebGL();
                  this.play();

                case 15:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, this, [[2, 9]]);
        }));
      }
    }, {
      key: "setCanvas",
      value: function setCanvas() {
        var canvas = this.instance.canvas;
        var _this$options = this.options,
            width = _this$options.width,
            height = _this$options.height;

        if (!canvas) {
          canvas = this.instance.canvas = document.createElement('canvas');
        }

        canvas.width = width;
        canvas.height = height;
        this.container.appendChild(canvas);
      }
    }, {
      key: "initWebGL",
      value: function initWebGL() {
        var canvas = this.instance.canvas;
        var _this$instance = this.instance,
            gl = _this$instance.gl,
            vertexShader = _this$instance.vertexShader,
            fragmentShader = _this$instance.fragmentShader,
            program = _this$instance.program;

        if (!canvas) {
          return;
        }

        if (!gl) {
          this.instance.gl = gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
          gl.disable(gl.BLEND);
          gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
          gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        } // 清除界面，解决同类型type切换MP4时，第一帧是上一个mp4最后一帧的问题


        gl.clear(gl.COLOR_BUFFER_BIT);

        if (gl) {
          gl.viewport(0, 0, canvas.width, canvas.height);

          if (!vertexShader) {
            vertexShader = this.instance.vertexShader = this.initVertexShader();
          }

          if (!fragmentShader) {
            fragmentShader = this.instance.fragmentShader = this.initFragmentShader();
          }

          if (!program) {
            program = this.instance.program = createProgram(gl, vertexShader, fragmentShader);
          }

          this.program = program;
          this.initTexture();
          this.initVideoTexture();
          return gl;
        }
      }
      /**
       * 顶点着色器
       */

    }, {
      key: "initVertexShader",
      value: function initVertexShader() {
        var gl = this.instance.gl;
        return createShader(gl, gl.VERTEX_SHADER, "attribute vec2 a_position; // \u63A5\u53D7\u9876\u70B9\u5750\u6807\n             attribute vec2 a_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             attribute vec2 a_alpha_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             varying vec2 v_alpha_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             varying   vec2 v_texcoord; // \u4F20\u9012\u7EB9\u7406\u5750\u6807\u7ED9\u7247\u5143\u7740\u8272\u5668\n             void main(void){\n                gl_Position = vec4(a_position, 0.0, 1.0); // \u8BBE\u7F6E\u5750\u6807\n                v_texcoord = a_texCoord; // \u8BBE\u7F6E\u7EB9\u7406\u5750\u6807\n                v_alpha_texCoord = a_alpha_texCoord; // \u8BBE\u7F6E\u7EB9\u7406\u5750\u6807\n             }");
      }
      /**
       * 片元着色器
       */

    }, {
      key: "initFragmentShader",
      value: function initFragmentShader() {
        var gl = this.instance.gl;
        var bgColor = "vec4(texture2D(u_image_video, v_texcoord).rgb, texture2D(u_image_video,v_alpha_texCoord).r);";
        var textureSize = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1; // const textureSize =0

        var sourceTexure = '';
        var sourceUniform = '';

        if (textureSize > 0) {
          var imgColor = [];
          var samplers = [];

          for (var i = 0; i < textureSize; i++) {
            imgColor.push("if(ndx == ".concat(i + 1, "){\n                        color = texture2D(u_image").concat(i + 1, ",uv);\n                    }"));
            samplers.push("uniform sampler2D u_image".concat(i + 1, ";"));
          }

          sourceUniform = "\n            ".concat(samplers.join('\n'), "\n            uniform float image_pos[").concat(textureSize * PER_SIZE, "];\n            vec4 getSampleFromArray(int ndx, vec2 uv) {\n                vec4 color;\n                ").concat(imgColor.join(' else '), "\n                return color;\n            }\n            ");
          sourceTexure = "\n            vec4 srcColor,maskColor;\n            vec2 srcTexcoord,maskTexcoord;\n            int srcIndex;\n            float x1,x2,y1,y2,mx1,mx2,my1,my2; //\u663E\u793A\u7684\u533A\u57DF\n\n            for(int i=0;i<".concat(textureSize * PER_SIZE, ";i+= ").concat(PER_SIZE, "){\n                if ((int(image_pos[i]) > 0)) {\n                  srcIndex = int(image_pos[i]);\n    \n                    x1 = image_pos[i+1];\n                    x2 = image_pos[i+2];\n                    y1 = image_pos[i+3];\n                    y2 = image_pos[i+4];\n                    \n                    mx1 = image_pos[i+5];\n                    mx2 = image_pos[i+6];\n                    my1 = image_pos[i+7];\n                    my2 = image_pos[i+8];\n    \n    \n                    if (v_texcoord.s>x1 && v_texcoord.s<x2 && v_texcoord.t>y1 && v_texcoord.t<y2) {\n                        srcTexcoord = vec2((v_texcoord.s-x1)/(x2-x1),(v_texcoord.t-y1)/(y2-y1));\n                         maskTexcoord = vec2(mx1+srcTexcoord.s*(mx2-mx1),my1+srcTexcoord.t*(my2-my1));\n                         srcColor = getSampleFromArray(srcIndex,srcTexcoord);\n                         maskColor = texture2D(u_image_video, maskTexcoord);\n                         srcColor.a = srcColor.a*(maskColor.r);\n                      \n                         bgColor = vec4(srcColor.rgb*srcColor.a,srcColor.a) + (1.0-srcColor.a)*bgColor;\n                      \n                    }   \n                }\n            }\n            ");
        }

        var fragmentSharder = "\n        precision lowp float;\n        varying vec2 v_texcoord;\n        varying vec2 v_alpha_texCoord;\n        uniform sampler2D u_image_video;\n        ".concat(sourceUniform, "\n        \n        void main(void) {\n            vec4 bgColor = ").concat(bgColor, "\n            ").concat(sourceTexure, "\n            // bgColor = texture2D(u_image[0], v_texcoord);\n            gl_FragColor = bgColor;\n        }\n        ");
        return createShader(gl, gl.FRAGMENT_SHADER, fragmentSharder);
      }
    }, {
      key: "initTexture",
      value: function initTexture() {
        var gl = this.instance.gl;
        var i = 1;

        if (!this.vapFrameParser || !this.vapFrameParser.srcData) {
          return;
        }

        var resources = this.vapFrameParser.srcData;

        for (var key in resources) {
          var resource = resources[key];
          this.textures.push(createTexture(gl, i, resource.img));

          var _sampler = gl.getUniformLocation(this.program, "u_image".concat(i));

          gl.uniform1i(_sampler, i);
          this.vapFrameParser.textureMap[resource.srcId] = i++;
        }

        var dumpTexture = gl.createTexture();
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, dumpTexture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
        this.videoTexture = createTexture(gl, i);
        var sampler = gl.getUniformLocation(this.program, "u_image_video");
        gl.uniform1i(sampler, i);
      }
    }, {
      key: "initVideoTexture",
      value: function initVideoTexture() {
        var gl = this.instance.gl;
        var vertexBuffer = gl.createBuffer();
        this.buffers.push(vertexBuffer);

        if (!this.vapFrameParser || !this.vapFrameParser.config || !this.vapFrameParser.config.info) {
          return;
        }

        var info = this.vapFrameParser.config.info;
        var ver = [];
        var vW = info.videoW,
            vH = info.videoH;

        var _info$rgbFrame = slicedToArray(info.rgbFrame, 4),
            rgbX = _info$rgbFrame[0],
            rgbY = _info$rgbFrame[1],
            rgbW = _info$rgbFrame[2],
            rgbH = _info$rgbFrame[3];

        var _info$aFrame = slicedToArray(info.aFrame, 4),
            aX = _info$aFrame[0],
            aY = _info$aFrame[1],
            aW = _info$aFrame[2],
            aH = _info$aFrame[3];

        var rgbCoord = computeCoord(rgbX, rgbY, rgbW, rgbH, vW, vH);
        var aCoord = computeCoord(aX, aY, aW, aH, vW, vH);
        ver.push.apply(ver, [-1, 1, rgbCoord[0], rgbCoord[3], aCoord[0], aCoord[3]]);
        ver.push.apply(ver, [1, 1, rgbCoord[1], rgbCoord[3], aCoord[1], aCoord[3]]);
        ver.push.apply(ver, [-1, -1, rgbCoord[0], rgbCoord[2], aCoord[0], aCoord[2]]);
        ver.push.apply(ver, [1, -1, rgbCoord[1], rgbCoord[2], aCoord[1], aCoord[2]]);
        var view = new Float32Array(ver);
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, view, gl.STATIC_DRAW);
        this.aPosition = gl.getAttribLocation(this.program, 'a_position');
        gl.enableVertexAttribArray(this.aPosition);
        this.aTexCoord = gl.getAttribLocation(this.program, 'a_texCoord');
        gl.enableVertexAttribArray(this.aTexCoord);
        this.aAlphaTexCoord = gl.getAttribLocation(this.program, 'a_alpha_texCoord');
        gl.enableVertexAttribArray(this.aAlphaTexCoord); // 将缓冲区对象分配给a_position变量、a_texCoord变量

        var size = view.BYTES_PER_ELEMENT;
        gl.vertexAttribPointer(this.aPosition, 2, gl.FLOAT, false, size * 6, 0); // 顶点着色器位置

        gl.vertexAttribPointer(this.aTexCoord, 2, gl.FLOAT, false, size * 6, size * 2); // rgb像素位置

        gl.vertexAttribPointer(this.aAlphaTexCoord, 2, gl.FLOAT, false, size * 6, size * 4); // rgb像素位置
      }
    }, {
      key: "drawFrame",
      value: function drawFrame() {
        var _this2 = this;

        var gl = this.instance.gl;

        if (!gl) {
          get(getPrototypeOf$1(WebglRenderVap.prototype), "drawFrame", this).call(this);

          return;
        }

        gl.clear(gl.COLOR_BUFFER_BIT);

        if (this.vapFrameParser) {
          var frame = Math.floor(this.video.currentTime * this.options.fps);
          var frameData = this.vapFrameParser.getFrame(frame);
          var posArr = [];

          if (frameData && frameData.obj) {
            frameData.obj.forEach(function (frame, index) {
              posArr[posArr.length] = +_this2.vapFrameParser.textureMap[frame.srcId];
              var info = _this2.vapFrameParser.config.info;
              var vW = info.videoW,
                  vH = info.videoH;

              var _frame$frame = slicedToArray(frame.frame, 4),
                  x = _frame$frame[0],
                  y = _frame$frame[1],
                  w = _frame$frame[2],
                  h = _frame$frame[3];

              var _frame$mFrame = slicedToArray(frame.mFrame, 4),
                  mX = _frame$mFrame[0],
                  mY = _frame$mFrame[1],
                  mW = _frame$mFrame[2],
                  mH = _frame$mFrame[3];

              var coord = computeCoord(x, y, w, h, vW, vH);
              var mCoord = computeCoord(mX, mY, mW, mH, vW, vH);
              posArr = posArr.concat(coord).concat(mCoord);
            });
          } //


          var size = (gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1) * PER_SIZE;
          posArr = posArr.concat(new Array(size - posArr.length).fill(0));
          this._imagePos = this._imagePos || gl.getUniformLocation(this.program, 'image_pos');
          gl.uniform1fv(this._imagePos, new Float32Array(posArr));
        }

        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, this.video); // 指定二维纹理方式

        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

        get(getPrototypeOf$1(WebglRenderVap.prototype), "drawFrame", this).call(this);
      }
    }, {
      key: "destroy",
      value: function destroy() {
        var _this$instance2 = this.instance,
            canvas = _this$instance2.canvas,
            gl = _this$instance2.gl;

        if (this.textures && this.textures.length) {
          for (var i = 0; i < this.textures.length; i++) {
            gl.deleteTexture(this.textures[i]);
          }
        }

        if (canvas) {
          canvas.parentNode && canvas.parentNode.removeChild(canvas);
        } // glUtil.cleanWebGL(gl, this.shaders, this.program, this.textures, this.buffers)


        get(getPrototypeOf$1(WebglRenderVap.prototype), "destroy", this).call(this);

        this.clearMemoryCache();
      }
    }, {
      key: "clearMemoryCache",
      value: function clearMemoryCache() {
        if (clearTimer) {
          clearTimeout(clearTimer);
        }

        clearTimer = setTimeout(function () {
          instances = {};
        }, 30 * 60 * 1000);
      }
    }]);

    return WebglRenderVap;
  }(VapVideo);

  var isCanWebGL;
  /**
   * @param options
   * @constructor
   * @return {null}
   */

  function index (options) {
    if (canWebGL()) {
      return new WebglRenderVap(Object.assign({}, options));
    } else {
      throw new Error('your browser not support webgl');
    }
  }

  function canWebGL() {
    if (typeof isCanWebGL !== 'undefined') {
      return isCanWebGL;
    }

    try {
      // @ts-ignore
      if (!window.WebGLRenderingContext) {
        return false;
      }

      var canvas = document.createElement('canvas');
      var context = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      isCanWebGL = !!context;
      context = null;
    } catch (err) {
      isCanWebGL = false;
    }

    return isCanWebGL;
  }

  return index;

})));

module stdcpp.span;

import stdcpp.xutility : StdNamespace;

extern (C++,(StdNamespace)):

/**
 * D language counterpart to C++ std::span.
 *
 * C++ reference: $(LINK2 https://en.cppreference.com/w/cpp/container/span)
 */

extern (C++,class) struct span(T, size_t N)
{
extern (D):
pragma(inline, true):

    ///
    alias element_type = T;
    ///
    alias size_type = size_t;
    ///
    alias difference_type = ptrdiff_t;
    ///
    alias pointer = element_type*;
    ///
    alias const_pointer = const(element_type)*;
    ///
    alias as_array this;

    //     // span!(element_type, Count) first(size_t Count)();

    //     // span!(element_type, Count) last(size_t Count)();

    private element_type* data_;
    private size_type size_;

    // this();
    this(T* data)
    {
        data_ = (data);
        size_ = N;
    }

    // (default) // copy ctor
    // this(ref const(span!(T, N)) other) const ;

    // (default) 
    // ref span!(T, N) opAssign(ref const(span!(T, N)) other) const ;

pure nothrow @nogc:
    ///
    size_type size() @safe const
    {
        return size_;
    }
    ///
    size_type size_bytes() const
    {
        return size * element_type.sizeof;
    }
    ///
    bool empty() @safe const
    {
        return (size_ == 0);
    }
    ///
    // ref element_type opIndex(size_type idx) const;
    ///
    ref element_type front() @safe
    {
        return data_[0];
    }
    ///
    ref element_type back() @safe
    {
        return this[size_ - 1];
    }
    ///
    element_type* data() @safe
    {
        return data_;
    }
    ///
    int begin() inout @safe const
    {
        return this[0];
    }
    ///
    int end() inout @safe const
    {
        return this[size_ - 1];
    }
    ///
    int rbegin() inout @safe const
    {
        return end();
    }
    ///
    int rend() inout @safe const
    {
        return begin();
    }

    /// Based on stdcpp.array
    version (CppRuntime_Windows)
    {
        ///
        inout(T)* data() inout @safe
        {
            return &_Elems[0];
        }
        ///
        ref inout(T)[size_] as_array() inout @safe
        {
            return _Elems[0 .. N];
        }
        ///
        ref inout(T) at(size_type i) inout @safe
        {
            return _Elems[0 .. N][i];
        }

    private:
        T[N ? N: 1] _Elems;
    }
    else version (CppRuntime_Gcc)
    {
        ///
        inout(T)* data() inout @safe
        {
            static if (N > 0)
            {
                return &_M_elems[0];
            }
            else
            {
                return null;
            }
        }
        ///
        ref inout(T)[N] as_array() inout @trusted
        {
            return data()[0 .. N];
        }
        ///
        ref inout(T) at(size_type i) inout @trusted
        {
            return data()[0 .. N][i];
        }

    private:
        static if (N > 0)
        {
            T[N] _M_elems;
        }
        else
        {
            struct _Placeholder
            {
            }

            _Placeholder _M_placeholder;
        }
    }
    else version (CppRuntime_Clang)
    {
        ///
        inout(T)* data() inout @trusted
        {
            static if (N > 0)
            {
                return &__elems_[0];
            }
            else
            {
                return cast(inout(T)*) __elems_.ptr;
            }
        }
        ///
        ref inout(T)[size_] as_array() inout @trusted
        {
            return data()[0 .. N];
        }
        ///
        ref inout(T) at(size_type i) inout @trusted
        {
            return data()[0 .. N][i];
        }

    private:
        static if (N > 0)
        {
            T[size_] __elems_;
        }
        else
        {
            struct _SpanInStructT
            {
                T[1] __data_;
            }

            align(_SpanInStructT.alignof)
            byte[_SpanInStructT.sizeof] __elems_ = void;
        }
    }
    else
    {
        static assert(false, "C++ runtime not supported");
    }
}

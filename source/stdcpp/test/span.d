/*******************************************************************************

    Tests for `std::span`

*******************************************************************************/

module stdcpp.test.span;
import stdcpp.span;

unittest {    
    int[10] a = [34, 56, 78, 23, 1, 0, 54, 94, 62, 5];
    span!(int, 10) b = span!(int, 10)(a.ptr);

    assert(b.size() == a.length);
    assert(b.rbegin == b.end);
    assert(b.begin == b.rend);
    assert(false == b.empty());
}
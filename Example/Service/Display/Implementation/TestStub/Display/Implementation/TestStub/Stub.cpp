#include <Display/Stub.hpp>
#include <Display/TestStub/Stub.hpp>

void Display::DoSomething ()
{
    Display::TestStub::PrintSomething ();
}
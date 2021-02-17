#include <Persistence/Stub.hpp>
#include <Persistence/TestStub/Stub.hpp>

void Persistence::DoSomething ()
{
    Persistence::TestStub::PrintSomething ();
}
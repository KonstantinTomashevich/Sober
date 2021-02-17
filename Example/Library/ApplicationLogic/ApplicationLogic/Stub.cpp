#include <ApplicationLogic/Stub.hpp>
#include <Display/Stub.hpp>
#include <Persistence/Stub.hpp>

void ApplicationLogic::DoSomething ()
{
    Display::DoSomething ();
    Persistence::DoSomething ();
}

//
//  ContactListener.h
//  runner
//
//  Created by Sven Holmgren on 1/8/13.
//
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Contact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const Contact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};
    
class ContactListener : public b2ContactListener {
        
    public:
        std::vector<Contact>_contacts;
        
        ContactListener();
        ~ContactListener();
        
        virtual void BeginContact(b2Contact* contact);
        virtual void EndContact(b2Contact* contact);
        virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
        virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
        
};
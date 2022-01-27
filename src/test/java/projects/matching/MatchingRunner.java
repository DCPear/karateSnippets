package projects.matching;

import com.intuit.karate.junit5.Karate;

class MatchingRunner {
    
    @Karate.Test
    Karate testUsers() {
        return Karate.run("matching").relativeTo(getClass());
    }

}

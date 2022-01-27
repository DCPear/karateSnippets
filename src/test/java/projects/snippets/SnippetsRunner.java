package projects.snippets;

import com.intuit.karate.junit5.Karate;

class SnippetsRunner {
    
    @Karate.Test
    Karate testUsers() {
        return Karate.run("snippets").relativeTo(getClass());
    }    

}

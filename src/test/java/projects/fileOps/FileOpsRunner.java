package projects.fileOps;

import com.intuit.karate.junit5.Karate;

class FileOpsRunner {
    
    @Karate.Test
    Karate testUsers() {
        return Karate.run("fileOps").relativeTo(getClass());
    }

}

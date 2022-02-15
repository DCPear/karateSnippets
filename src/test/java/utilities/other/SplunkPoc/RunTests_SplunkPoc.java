package utilities.other.SplunkPoc;

import com.intuit.karate.KarateOptions;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/*
    Class for running of Automation tests. Please refer to the below Tag options to run a subset of test scenarios.
    To run specific tests/features/projects specify what to run in the '@KarateOptions(tags = {"@replaceMe"})' section
    Examples :
     - To run all tests for a project: "@project:projectName"
     - To exclude certain tests/stories: "~@test:testname"
     - example to run specific tests but exclude particular Tags: "@story:demo-story,@test:demo-01", "~@test:demo-02","~@test:demo-04"
 */

@KarateOptions(tags = {"~@ignore"})
class RunTests_SplunkPoc {

    @Test
    public void runTests() {
        Results results = Runner.parallel(getClass(), 1);
        generateReport(results.getReportDir());
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
        List<String> jsonPaths = new ArrayList(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "SplunkPoc");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }
}

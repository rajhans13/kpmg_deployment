import java.util.ArrayList;
import java.util.List;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

public class Main {
    public static void main(String[] args) {

        String html = getHTML("https://news.ycombinator.com");
        //System.out.println(html);

        //String html = "<html><body><p>Hello, world! <a href='https://www.example.com'>Link</a></p><a href='https://www.example.com'>Link2</a></body></html>";
        
        int count = 0;

        List<String> links = getLinks(html);
        for (String link : links) {
            if(link.contains("https") && !link.contains("news.ycombinator.com") && count < 20){
                System.out.println(link.replaceAll("<[^>]*>", ""));
                count++;
            }
        }
    }

    public static String getHTML(String urlString) {
        StringBuilder html = new StringBuilder();
        try {
            URL url = new URL(urlString);
            BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));

            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                html.append(inputLine);
            }
            in.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return html.toString();
    }

    public static List<String> getLinks(String html) {
        List<String> links = new ArrayList<>();
        int startIndex = 0;
        while (startIndex != -1) {
            startIndex = html.indexOf("<a", startIndex);
            if (startIndex != -1) {
                int endIndex = html.indexOf("</a>", startIndex) + 4;
                links.add(html.substring(startIndex, endIndex));
                startIndex = endIndex;
            }
        }
        return links;
    }
}

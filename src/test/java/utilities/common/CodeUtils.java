package utilities.common;

import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.Map;

import static java.net.URLDecoder.decode;
import static java.net.URLEncoder.encode;

public class CodeUtils {

    private static class Code {
        final String first;
        final String second;

        Code(String first, String second) {
            this.first = first;
            this.second = second;
        }
    }

    private static final Code[] html = new Code[]{
            new Code("&nbsp;", " "),
            new Code("&lt;", "<"),
            new Code("&gt;", ">"),
            new Code("&amp;", "&"),
            new Code("&quot;", "\""),
            new Code("&apos;", "'"),
            new Code("&cent;", "¢"),
            new Code("&pound;", "£"),
            new Code("&yen;", "¥"),
            new Code("&euro;", "€"),
            new Code("&copy;", "©"),
            new Code("&reg;", "®")
    };

    public static String base64Decode(String toDecode) {
        return new String(Base64.getDecoder().decode(toDecode));
    }

    public static String base64Encode(String toEncode) {
        return new String(Base64.getEncoder().encodeToString(toEncode.getBytes()));
    }

    public static String urlEncode(Map<String, Object> json) throws UnsupportedEncodingException {
        StringBuilder builder = new StringBuilder();
        for (Map.Entry<String, Object> entry : json.entrySet()) {
            builder.append(entry.getKey())
                    .append('=')
                    .append(urlEncode(entry.getValue().toString()))
                    .append('&');
        }
        builder.setLength(builder.length() - 1);
        return builder.toString();
    }

    public static String urlEncode(String toEncode) throws UnsupportedEncodingException {
        return encode(toEncode, "UTF-8");
    }

    public static String urlDecode(String toDecode) throws UnsupportedEncodingException {
        String decoded = decode(toDecode, "UTF-8");
        for (Code code : html) {
            decoded = decoded.replaceAll(code.first, code.second);
        }
        return decoded;
    }
}

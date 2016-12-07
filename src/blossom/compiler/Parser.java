package blossom.compiler;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class Parser {

	String text;
	int position;
	
	public Parser(String text) {
		this.text = text;
		this.position = 0;
	}
	
	abstract void parse();
	
	protected void consumeWhitespace() {
		while (Character.isWhitespace(text.charAt(position))) {
			position ++;
		}
	}
	
	protected boolean beginsWith(String string) {
		return text.substring(position).startsWith(string);
	}
	
	protected String consume(String string) {
		if (beginsWith(string)) {
			position += string.length();
			return string;
		}
		return "";
	}
	
	protected String consume(Pattern pattern) {
		Matcher matcher = pattern.matcher(text.substring(position));
		if (matcher.find() && matcher.start() == 0)
		{
			int end = matcher.end();
			String result = text.substring(position, position + end);
			position += result.length();
			return result; 
		}
		return "";
	}
	
	protected boolean eof() {
		return position == text.length();
	}
	
}

package blossom.compiler;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class Parser {

	protected String text;
	protected int position;
	protected boolean finished;
	
	public Parser(String text) {
		this.text = text;
		this.position = 0;
		this.finished = false;
		if (text.isEmpty()) {
			this.finished = true;
		}
	}

	public boolean isFinished() {
		return finished;
	}
	
	protected void consumeWhitespace() {
		while (!eof() && Character.isWhitespace(text.charAt(position))) {
			position ++;
		}
	}
	
	protected boolean beginsWith(String string) {
		return text.substring(position).startsWith(string);
	}
	
	protected boolean beginsWith(Pattern pattern) {
		Matcher matcher = pattern.matcher(text.substring(position));
		return (matcher.find() && matcher.start() == 0);
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

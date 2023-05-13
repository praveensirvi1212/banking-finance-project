package com.project.staragile.banking;

import javax.websocket.server.PathParam;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
public class AccountController {
	
	@Autowired
	AccountService accountService;
	
	@Autowired
	ObjectMapper objectMapper;
	
	@GetMapping("/sayHello")
	public String sayHello() {
		return "Hello from CBS Bank";
	}
	
	
	@GetMapping("/createAccount")
	public Account createAccount(){
		return accountService.createAccount();
	}
	
	@PostMapping("/registerAccount")
	public Account registerAccount(@RequestBody Account account) {
		if(account != null) {
			return accountService.registerAccount(account);
		}
		System.out.println("post called");
		return account;
	}
	
	@GetMapping("/getAccount/{accountNumber}")
	public Account getAccountDetails(@PathVariable(value="accountNumber") int accountNumber) {
		System.out.println(accountNumber);
		Account account = accountService.getAccountDetails(accountNumber);
		return account;
	}

}

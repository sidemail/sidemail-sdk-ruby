# Sidemail Ruby Library

Official Sidemail.io Ruby library providing convenient access to the Sidemail API from Ruby applications.

## Requirements

- Ruby 2.6+

## Installation

Using RubyGems:

```bash
gem install sidemail
```

Or using Bundler:

```bash
bundle add sidemail
```

## Usage

First, the client needs to be configured with your project's API key, which you can find in the Sidemail Dashboard after you sign up.

```ruby
require "sidemail"

# Initialize with API key
sm = Sidemail.new(api_key: "your-api-key")

# Or set environment variable SIDEMAIL_API_KEY
# sm = Sidemail.new
```

```ruby
response = sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "you@example.com",
  fromName: "Your App",
  templateName: "Welcome",
  templateProps: { foo: "bar" }
)

puts "Email sent! ID: #{response.id}"
```

The response looks like:

```json
{
  "id": "5e858953daf20f3aac50a3da",
  "status": "queued"
}
```

Shortcut `sm.send_email(...)` calls `sm.email.send(...)` under the hood.

### Authentication

Explicit key:

```ruby
require "sidemail"
sm = Sidemail.new(api_key: "your-api-key")
```

Or if you set environment variable `SIDEMAIL_API_KEY`, then simply:

```ruby
require "sidemail"
sm = Sidemail.new # reads SIDEMAIL_API_KEY
```

### Client configuration

```ruby
require "sidemail"

sm = Sidemail.new(
  api_key: "your-api-key",
  base_url: "https://api.sidemail.io/v1", # override for testing/mocking
  timeout: 10.0,  # per-request timeout (seconds)
  http_client: custom_http_client, # custom Net::HTTP client (proxies, retries, etc.)
)
```

## Email Sending Examples

### Password reset template

```ruby
sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "you@example.com",
  fromName: "Your App",
  templateName: "Password reset",
  templateProps: { resetUrl: "https://your.app/reset?token=123" }
)
```

### Schedule email delivery

```ruby
require "date"

# Schedule for 60 minutes from now
scheduled_iso = (Time.now + 60 * 60).utc.iso8601

sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "your@startup.com",
  fromName: "Startup name",
  templateName: "Welcome",
  templateProps: { firstName: "Patrik" },
  scheduledAt: scheduled_iso
)
```

### Template with dynamic list

```ruby
sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "your@startup.com",
  fromName: "Startup name",
  templateName: "Template with dynamic list",
  templateProps: {
    list: [
      { text: "Dynamic list" },
      { text: "allows you to generate email template content" },
      { text: "based on template props." }
    ]
  }
)
```

### Custom HTML email

```ruby
sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "your@startup.com",
  fromName: "Startup name",
  subject: "Testing html only custom emails :)",
  html: "<html><body><h1>Hello world! 👋</h1></body></html>"
)
```

### Custom plain text email

```ruby
sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "your@startup.com",
  fromName: "Startup name",
  subject: "Testing plain-text only custom emails :)",
  text: "Hello world! 👋"
)
```

## Error handling

The SDK raises `Sidemail::Error` for all errors. API errors include `message`, `http_status`, `error_code`, and `more_info`.

```ruby
require "sidemail"

sm = Sidemail.new(api_key: "your-api-key")

begin
  sm.send_email(
    toAddress: "user@example.com",
    fromAddress: "you@example.com",
    subject: "Hello",
    text: "Hello"
  )
rescue Sidemail::Error => e
  puts e.message
  if e.http_status # API error
    puts "#{e.http_status} #{e.error_code} #{e.more_info}"
  end
end
```

## Response objects

Most responses are wrapped in a `Resource` enabling attribute access while remaining hash-like.

- Methods return `Resource` wrappers (attribute + hash access); unwrap via `.to_h`.
- Original JSON available via `.raw`.

```ruby
response = sm.email.get("email-id")
puts "#{response.email.id} #{response.email.status}"
puts response.email["id"] # hash-style
raw_json = response.raw # original JSON mapping
flat_hash = response.to_h # fully unwrapped hash
```

## Attachments helper

```ruby
require "sidemail"

file_content = File.read("invoice.pdf")
attachment = Sidemail.file_to_attachment("invoice.pdf", file_content)

sm.send_email(
  toAddress: "user@email.com",
  fromAddress: "you@example.com",
  subject: "Invoice",
  text: "Invoice attached.",
  attachments: [attachment]
)
```

## Auto-pagination

List/search methods return a `PaginatedResponse` containing the first page in `result.data`. Iterate across all pages with `auto_paginate`.

```ruby
result = sm.contacts.list(limit: 50)

result.auto_paginate.each do |contact|
  puts contact.emailAddress
end
```

Supported auto-paging methods:

- `sm.contacts.list`
- `sm.contacts.query`
- `sm.email.search`
- `sm.messenger.list`

## Email Methods

### Search emails

Paginated (supports auto-pagination).

```ruby
result = sm.email.search(
  query: {
    toAddress: "john.doe@example.com",
    status: "delivered",
    templateProps: { foo: "bar" }
  },
  limit: 50
)

puts "First page count: #{result.items.count}"
result.auto_paginate.each do |email|
  puts "#{email.id} #{email.status}"
end
```

### Retrieve a specific email

```ruby
resp = sm.email.get("SIDEMAIL_EMAIL_ID")
puts resp.email
```

### Delete a scheduled email

Only scheduled (future) emails can be deleted.

```ruby
resp = sm.email.delete("SIDEMAIL_EMAIL_ID")
puts "Deleted: #{resp.deleted}"
```

## Contact Methods

### Create or update a contact

```ruby
resp = sm.contacts.create_or_update(
  emailAddress: "marry@lightning.com",
  identifier: "123",
  customProps: {
    name: "Marry Lightning"
    # ... more props ...
  }
)
puts "Contact status: #{resp.status}"
```

### Find a contact

```ruby
resp = sm.contacts.find("marry@lightning.com")
if resp.contact
  puts "Found contact: #{resp.contact.emailAddress}"
end
```

### List all contacts

```ruby
result = sm.contacts.list(limit: 50)
puts "Has more: #{result.has_more}"
result.auto_paginate.each do |c|
  puts c.emailAddress
end
```

### Query contacts (filtering)

```ruby
result = sm.contacts.query(limit: 100, query: { "customProps.plan" => "pro" })
result.auto_paginate.each do |c|
  puts c.emailAddress
end
```

### Delete a contact

```ruby
resp = sm.contacts.delete("marry@lightning.com")
puts resp
```

## Project Methods

Linked projects are associated with the parent project of the API key used to initialize Sidemail. After creation, update the design to personalize templates.

### Create a linked project

```ruby
project = sm.project.create(name: "Customer X linked project")
# Important! Save project.apiKey for later use
```

### Update a linked project

```ruby
updated = sm.project.update(
  name: "New name",
  emailTemplateDesign: {
    logo: {
      sizeWidth: 50,
      href: "https://example.com",
      file: "PHN2ZyBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGZpbGwtcnVsZT0iZXZlbm9kZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjIiIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJtMTIgNS43MmMtMi42MjQtNC41MTctMTAtMy4xOTgtMTAgMi40NjEgMCAzLjcyNSA0LjM0NSA3LjcyNyA5LjMwMyAxMi41NC4xOTQuMTg5LjQ0Ni4yODMuNjk3LjI4M3MuNTAzLS4wOTQuNjk3LS4yODNjNC45NzctNC44MzEgOS4zMDMtOC44MTQgOS4zMDMtMTIuNTQgMC01LjY3OC03LjM5Ni02Ljk0NC0xMC0yLjQ2MXoiIGZpbGwtcnVsZT0ibm9uemVybyIvPjwvc3ZnPg==",
    },
    font: { name: "Acme" },
    colors: { highlight: "#0000FF", isDarkModeEnabled: true },
    unsubscribeText: "Darse de baja",
    footerTextTransactional: "You're receiving these emails because you registered for Acme Inc."
  }
)
```

### Get a project

```ruby
project = sm.project.get
puts "#{project.id} #{project.name}"
```

### Delete a linked project

```ruby
resp = sm.project.delete
puts resp
```

## Messenger API (newsletters)

```ruby
result = sm.messenger.list(limit: 20)
result.auto_paginate.each do |m|
  puts "#{m.id} #{m.name}"
end

messenger = sm.messenger.get("messenger-id")
created = sm.messenger.create(subject: "My Messenger", markdown: "Broadcast message...")
updated = sm.messenger.update("messenger-id", name: "Updated name")
deleted = sm.messenger.delete("messenger-id")
```

## Sending domains API

```ruby
domains = sm.domains.list
domain = sm.domains.create(name: "example.com")
deleted = sm.domains.delete("domain-id")
```

## More Info

Visit [Sidemail docs](https://sidemail.io/docs) for more information.

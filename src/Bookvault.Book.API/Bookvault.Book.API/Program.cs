using Bogus;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

var books = new Faker<Book>()
    .StrictMode(true)
    .RuleFor(b => b.BookId, (faker) => Guid.NewGuid().ToString())
    .RuleFor(b => b.Title, (faker) => faker.Commerce.ProductName())
    .Generate(10);


app.MapGet("/books", () => Results.Ok(books))
    .Produces<Book[]>(StatusCodes.Status200OK)
    .WithName("GetBooks");

app.UseHttpsRedirection();

app.Run();

public class Book
{
    public string BookId => Guid.NewGuid().ToString();
    public string Title { get; set; }
}
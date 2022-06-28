using Bogus;
using Bookvault.Book.API.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Bookvault.Book.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookController : Controller
    {
        private readonly ILogger<BookController> _logger;

        public BookController(ILogger<BookController> logger)
        {
            _logger = logger;
        }

        [HttpGet("/books",Name = "GetBooks")]
        public ActionResult<List<Book>> GetBooks()
        {
            try
            {
                _logger.LogInformation("Retrieving all books");

                var books = new Faker<Book>()
                    .StrictMode(true)
                    .RuleFor(b => b.Id, (fake) => Guid.NewGuid().ToString())
                    .RuleFor(b => b.Title, (fake) => fake.Commerce.ProductName())
                    .RuleFor(b => b.Category, (fake) => fake.PickRandom<string>(new List<string> { "Romance", "Fiction", "Sci-Fi", "Non-Fiction", "Biography", "Education", "Thriller" }))
                    .RuleFor(b => b.Author, (fake) => fake.PickRandom<string>(new List<string> { "Joe Bloggs", "Jane Smith", "Sky Blue", "Lisa Marcs", "Will Johns", "Don Small", "Arthur Morgan", "Michael Townley", "Ashley Smith" }))
                    .RuleFor(b => b.Price, (fake) => fake.Random.Decimal(9.99m, 17.99m))
                    .Generate(10);

                return new OkObjectResult(books);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetBooks)}: {ex.Message}");
                throw;
            }      
        }
    }
}

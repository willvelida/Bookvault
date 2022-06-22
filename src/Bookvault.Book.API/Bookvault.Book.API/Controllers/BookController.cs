using Bogus;
using Microsoft.AspNetCore.Mvc;

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
        public ActionResult<List<Book>> Get()
        {
            try
            {
                _logger.LogInformation("Retrieving all books");

                var books = new Faker<Book>()
                    .StrictMode(true)
                    .RuleFor(b => b.BookId, (fake) => Guid.NewGuid().ToString())
                    .RuleFor(b => b.Title, (fake) => fake.Commerce.ProductName())
                    .Generate(10);

                _logger.LogInformation("Books retrieved");

                return new OkObjectResult(books);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(Get)}: {ex.Message}");
                throw;
            }      
        }
    }
}

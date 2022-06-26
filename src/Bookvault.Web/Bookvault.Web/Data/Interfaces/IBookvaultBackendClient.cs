using Refit;

namespace Bookvault.Web.Data.Interfaces
{
    public interface IBookvaultBackendClient
    {
        [Get("/books")]
        Task<List<Book>> GetBooks();

        [Get("/books/{id}")]
        Task<Book> GetBookById(string id);

        [Post("/books")]
        Task<Book> PostBook(Book book);

        [Put("/books/{id}")]
        Task UpdateBookById(string id, Book book);

        [Delete("/books/{id}")]
        Task DeleteBookById(string id);

        [Get("/inventory/{productId}")]
        Task<int> GetInventory(string productId);
    }
}

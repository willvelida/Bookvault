using Refit;

namespace Bookvault.Web.Data.Interfaces
{
    public interface IBookvaultBackendClient
    {
        [Get("/books")]
        Task<List<Book>> GetBooks();

        [Get("/books/{id}")]
        Task<Book> GetBookById(long id);

        [Post("/books")]
        Task<Book> PostBook(Book book);

        [Put("/books/{id}")]
        Task UpdateBookById(long id, Book book);

        [Delete("/books/{id}")]
        Task DeleteBookById(long id);

        [Get("/inventory/{productId}")]
        Task<int> GetInventory(int productId);
    }
}

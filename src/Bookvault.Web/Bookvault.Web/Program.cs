using Bookvault.Web.Data;
using Bookvault.Web.Data.Interfaces;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddEnvironmentVariables();

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddHttpClient("Books", (httpClient) => httpClient.BaseAddress = new Uri(builder.Configuration.GetValue<string>("BooksApi")));
builder.Services.AddHttpClient("Inventory", (httpClient) => httpClient.BaseAddress = new Uri(builder.Configuration.GetValue<string>("InventoryApi")));
builder.Services.AddScoped<IBookvaultBackendClient, BookvaultBackendClient>();
builder.Services.AddMemoryCache();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
